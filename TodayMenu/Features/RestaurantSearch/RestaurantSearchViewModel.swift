//
//  RestaurantSearchViewModel.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class RestaurantSearchViewModel: NSObject {
    
    private let disposeBag = DisposeBag()
    private lazy var locationManager = CLLocationManager()
    private let currentLocationRelay = BehaviorRelay<CLLocation?>(value: nil)
    
    struct Input {
        let searchButtonTapped: Observable<Void>
        let searchText: Observable<String>
    }
    
    struct Output {
        let searchResults: Driver<[RestaurantData]>
        let errorMessage: Driver<String>
    }
    
    private let errorMessage = PublishRelay<String>()
    
    override init() {
        super.init()
        setupLocationManager()
        requestLocation()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func requestLocation() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage.accept(LocationError.authorizationDenied.message)
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            // TODO: 위치 권한 껐을때 처리
            break
        }
    }
    
    func transform(input: Input) -> Output {
        let searchResults = PublishRelay<[RestaurantData]>()
        
        // 검색 버튼 탭 처리
        input.searchButtonTapped
            .withLatestFrom(input.searchText)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .flatMapLatest { [weak self] query -> Observable<[RestaurantData]> in
                guard let self = self else { return .empty() }
                return self.searchRestaurant(query: query)
            }
            .subscribe(with: self) { owner, restaurants in
                searchResults.accept(restaurants)
            } onError: { owner, _ in
                owner.errorMessage.accept("검색 중 오류가 발생했습니다.")
            }
            .disposed(by: disposeBag)
        
        return Output(
            searchResults: searchResults.asDriver(onErrorJustReturn: []),
            errorMessage: errorMessage.asDriver(onErrorJustReturn: "")
        )
    }
    
    private func searchRestaurant(query: String) -> Observable<[RestaurantData]> {
        // 현재 위치 가져오기
        let location = currentLocationRelay.value
        let latitude: String
        let longitude: String
        
        if let location = location {
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
        } else {
            // 위치를 가져오지 못한 경우 기본 위치 값 지정
            latitude = "37.5665"
            longitude = "126.9780"
        }
        
        let searchDataSet = NetworkRouter.SearchPlaceDataSet(
            query: query,
            categoryGroupCode: "FD6",
            latitude: latitude,
            longitude: longitude
        )
        
        return NetworkManager.shared
            .callRequest(router: .searchPlace(searchPlaceDataSet: searchDataSet), decodingType: MapData.self)
            .map { result in
                switch result {
                case .success(let mapData):
                    return mapData.documents
                case .failure(let error):
                    print("검색 실패: \(error)")
                    return []
                }
            }
    }
}

// MARK: - CLLocationManagerDelegate
extension RestaurantSearchViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocationRelay.accept(location)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 가져오기 실패: \(error.localizedDescription)")
    }
}
