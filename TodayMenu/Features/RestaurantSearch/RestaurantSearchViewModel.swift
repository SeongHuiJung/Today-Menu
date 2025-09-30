//
//  RestaurantSearchViewModel.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import Foundation
import RxSwift
import RxCocoa

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
    
    func transform(input: Input) -> Output {
        let searchResults = PublishRelay<[RestaurantData]>()
        let errorMessage = PublishRelay<String>()
        
        // 검색 버튼 탭 처리
        input.searchButtonTapped
            .withLatestFrom(input.searchText)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .flatMapLatest { [weak self] query -> Observable<[RestaurantData]> in
                guard let self = self else { return .empty() }
                return self.searchRestaurant(query: query)
            }
            .subscribe(onNext: { restaurants in
                searchResults.accept(restaurants)
            }, onError: { error in
                errorMessage.accept("검색 중 오류가 발생했습니다.")
            })
            .disposed(by: disposeBag)
        
        return Output(
            searchResults: searchResults.asDriver(onErrorJustReturn: []),
            errorMessage: errorMessage.asDriver(onErrorJustReturn: "")
        )
    }
    
    private func searchRestaurant(query: String) -> Observable<[RestaurantData]> {
        // 임시 좌표값 (서울 시청 기준)
        let latitude = "37.5665"
        let longitude = "126.9780"
        
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
