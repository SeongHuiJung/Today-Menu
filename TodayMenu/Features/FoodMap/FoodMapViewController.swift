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
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupMapView()
        bind()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "지도"
    }
    
    private func setupMapView() {
        mainView.mapView.showsUserLocation = true
    }
    
    private func bind() {
        let input = FoodMapViewModel.Input(
            showCurrentLocationTap: mainView.locationButton.rx.tap.asObservable().startWith(())
        )
        
        let output = viewModel.transform(input: input)
        
        // 위치 업데이트
        output.locationUpdate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                self?.moveMapToLocation(location.coordinate)
            })
            .disposed(by: disposeBag)
        
        // 권한 상태 변경
        output.authorizationStatus
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                self?.handleAuthorizationStatus(status)
            })
            .disposed(by: disposeBag)
        
        // 위치 에러
        output.locationError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showLocationError(error)
                // 에러 발생 시 기본 위치로 이동
                if case .locationServiceDisabled = error {
                    self?.moveMapToLocation(CLLocationCoordinate2D(latitude: 37.4921, longitude: 127.0232))
                } else if case .authorizationDenied = error {
                    self?.moveMapToLocation(CLLocationCoordinate2D(latitude: 37.4921, longitude: 127.0232))
                }
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
}
