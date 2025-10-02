//
//  FoodMapViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import CoreLocation

final class FoodMapViewController: UIViewController {
    
    private let viewModel = FoodMapViewModel()
    private let disposeBag = DisposeBag()
    private let mainView = FoodMapView()
    private let repository = ReviewRepository()
    
    private let viewWillAppearSubject = PublishRelay<Void>()
    private var currentRestaurant: Restaurant?
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupMapView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.accept(())
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "지도"
    }
    
    private func setupMapView() {
        mainView.mapView.showsUserLocation = true
        mainView.mapView.delegate = self
        
        mainView.floatingView.onClose = { [weak self] in
            self?.mainView.hideFloatingView()
        }
    
        mainView.floatingView.onReviewButtonTap = { [weak self] in
            self?.showReviewList()
        }
    }
    
    private func bind() {
        let input = FoodMapViewModel.Input(
            showCurrentLocationTap: mainView.locationButton.rx.tap.asObservable().startWith(()),
            viewWillAppear: viewWillAppearSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.locationUpdate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                self?.moveMapToLocation(location.coordinate)
            })
            .disposed(by: disposeBag)
        
        output.authorizationStatus
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                self?.handleAuthorizationStatus(status)
            })
            .disposed(by: disposeBag)
        
        output.locationError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showLocationError(error)
                if case .locationServiceDisabled = error {
                    self?.moveMapToLocation(CLLocationCoordinate2D(latitude: 37.4921, longitude: 127.0232))
                } else if case .authorizationDenied = error {
                    self?.moveMapToLocation(CLLocationCoordinate2D(latitude: 37.4921, longitude: 127.0232))
                }
            })
            .disposed(by: disposeBag)
        
        output.restaurants
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] restaurants in
                self?.addRestaurantAnnotations(restaurants)
            })
            .disposed(by: disposeBag)
    }
    
    private func moveMapToLocation(_ coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mainView.mapView.setRegion(region, animated: true)
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mainView.mapView.showsUserLocation = true
        case .denied, .restricted:
            mainView.mapView.showsUserLocation = false
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    private func showLocationError(_ error: LocationError) {
        let alert = UIAlertController(
            title: error.title,
            message: error.message,
            preferredStyle: .alert
        )
        
        if error.needsSettingsAction {
            alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        } else {
            alert.addAction(UIAlertAction(title: "확인", style: .default))
        }
        
        present(alert, animated: true)
    }
    
    private func showReviewList() {
        guard let restaurant = currentRestaurant else { return }
        
        let reviewListVC = RestaurantReviewListViewController(restaurant: restaurant)
        navigationController?.pushViewController(reviewListVC, animated: true)
    }
}

// MARK: - Restaurant Annotations
extension FoodMapViewController {
    private func addRestaurantAnnotations(_ restaurants: [Restaurant]) {
        let existingAnnotations = mainView.mapView.annotations.filter { !($0 is MKUserLocation) }
        mainView.mapView.removeAnnotations(existingAnnotations)
        
        let annotations = restaurants.map { restaurant in
            RestaurantAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: restaurant.latitude,
                    longitude: restaurant.longitude
                ),
                title: restaurant.name,
                subtitle: restaurant.cuisine,
                restaurant: restaurant
            )
        }
        
        mainView.mapView.addAnnotations(annotations)
    }
    
    private func showRestaurantDetail(for restaurant: Restaurant) {
        currentRestaurant = restaurant
        repository.fetchReviewsByRestaurantId(restaurantId: restaurant.restaurantId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reviews in
                guard let self = self else { return }
                self.displayRestaurantInfo(restaurant: restaurant, reviews: reviews)
            })
            .disposed(by: disposeBag)
    }
    
    private func displayRestaurantInfo(restaurant: Restaurant, reviews: [Review]) {
        guard !reviews.isEmpty else { return }
        
        let lastVisit = reviews.map { $0.ateAt }.max() ?? Date()
        let averageRating = reviews.reduce(0.0) { $0 + $1.rating } / Double(reviews.count)
        
        mainView.showFloatingView(
            restaurantName: restaurant.name,
            lastVisit: lastVisit,
            averageRating: averageRating,
            cuisine: restaurant.cuisine
        )
    }
    
    private func getZoomLevel(for mapView: MKMapView) -> Double {
        let region = mapView.region
        let span = region.span.longitudeDelta
        let zoomLevel = log2(360 / span)
        return zoomLevel
    }
}

// MARK: - MKMapViewDelegate
extension FoodMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let restaurantAnnotation = annotation as? RestaurantAnnotation else {
            return nil
        }
        
        let identifier = "RestaurantAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? RestaurantAnnotationView
        
        if annotationView == nil {
            annotationView = RestaurantAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.configure(with: restaurantAnnotation)
        
        // 현재 줌 레벨에 따라 라벨 표시
        let zoomLevel = getZoomLevel(for: mapView)
        annotationView?.updateLabelVisibility(zoomLevel: zoomLevel)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomLevel = getZoomLevel(for: mapView)
        
        // 모든 annotation view의 라벨 가시성 업데이트
        for annotation in mapView.annotations {
            if let view = mapView.view(for: annotation) as? RestaurantAnnotationView {
                view.updateLabelVisibility(zoomLevel: zoomLevel)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? RestaurantAnnotation,
              let restaurant = annotation.restaurant else {
            return
        }
        showRestaurantDetail(for: restaurant)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mainView.hideFloatingView()
    }
}

// MARK: - RestaurantAnnotation
class RestaurantAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let restaurant: Restaurant?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, restaurant: Restaurant? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.restaurant = restaurant
        super.init()
    }
}
