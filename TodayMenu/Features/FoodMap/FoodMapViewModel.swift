//
//  FoodMapViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

final class FoodMapViewModel: NSObject {
    
    private let disposeBag = DisposeBag()
    private lazy var locationManager = CLLocationManager()
    
    // Subjects
    private let locationUpdateSubject = PublishSubject<CLLocation>()
    private let authorizationStatusSubject = PublishSubject<CLAuthorizationStatus>()
    private let locationErrorSubject = PublishSubject<LocationError>()
    
    struct Input {
        let showCurrentLocationTap: Observable<Void>
    }
    
    struct Output {
        let locationUpdate: Observable<CLLocation>
        let authorizationStatus: Observable<CLAuthorizationStatus>
        let locationError: Observable<LocationError>
        let initialLocation: Observable<CLLocationCoordinate2D>
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func transform(input: Input) -> Output {
        // 위치 버튼 탭
        input.showCurrentLocationTap
            .subscribe(onNext: { [weak self] in
                self?.checkDeviceLocationSetting()
            })
            .disposed(by: disposeBag)
        
        // 초기 위치
        let initialLocation = Observable.just(CLLocationCoordinate2D(latitude: 37.4921, longitude: 127.0232))
        
        return Output(
            locationUpdate: locationUpdateSubject.asObservable(),
            authorizationStatus: authorizationStatusSubject.asObservable(),
            locationError: locationErrorSubject.asObservable(),
            initialLocation: initialLocation
        )
    }
    
    // MARK: - Location Methods
    func checkDeviceLocationSetting() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization()
                }
            } else {
                DispatchQueue.main.async {
                    self.locationErrorSubject.onNext(.locationServiceDisabled)
                }
            }
        }
    }
    
    private func checkCurrentLocationAuthorization() {
        var status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        authorizationStatusSubject.onNext(status)
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            locationErrorSubject.onNext(.authorizationDenied)
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        @unknown default:
            locationErrorSubject.onNext(.unknown)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension FoodMapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        locationUpdateSubject.onNext(location)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkDeviceLocationSetting()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
        checkDeviceLocationSetting()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error.localizedDescription)
        locationErrorSubject.onNext(.updateFailed(error.localizedDescription))
    }
}

// MARK: - LocationError
enum LocationError {
    case locationServiceDisabled
    case authorizationDenied
    case updateFailed(String)
    case unknown
    
    var title: String {
        return "위치 접근 요청"
    }
    
    var message: String {
        switch self {
        case .locationServiceDisabled:
            return "기기의 위치 권한이 꺼져 있어 위치 권한을 요청할 수 없습니다. \n[설정 > 개인정보 보호 및 보안 > 위치 서비스] 에서 위치 서비스를 허용해 주세요."
        case .authorizationDenied:
            return "위치 정보를 얻을 수 없습니다. 'TodayMenu' 앱의 위치 권한을 허용해 주세요."
        case .updateFailed(let errorMessage):
            return "위치 업데이트 실패: \(errorMessage)"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
    
    var needsSettingsAction: Bool {
        switch self {
        case .authorizationDenied:
            return true
        default:
            return false
        }
    }
}
