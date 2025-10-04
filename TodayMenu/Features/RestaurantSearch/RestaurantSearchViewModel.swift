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

final class RestaurantSearchViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchButtonTapped: Observable<Void>
        let searchText: Observable<String>
    }
    
    struct Output {
        let searchResults: Driver<[RestaurantData]>
        let errorMessage: Driver<String>
    }
    
    private let errorMessage = PublishRelay<String>()
    
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
        // FoodMapViewModel의 현재 위치 가져오기
        let location = FoodMapViewModel.shared.currentLocation.value
        let latitude: String
        let longitude: String
        
        if let location = location {
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
        } else {
            // 위치를 가져오지 못한 경우 기본 위치 값 지정 (서울시청)
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
            .map { [weak self] result in
                switch result {
                case .success(let mapData):
                    return mapData.documents
                case .failure(let error):
                    self?.errorMessage.accept(error.message)
                    return []
                }
            }
    }
}
