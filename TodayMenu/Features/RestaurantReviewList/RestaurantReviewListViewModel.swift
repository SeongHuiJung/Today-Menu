//
//  RestaurantReviewListViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import Foundation
import RxSwift
import RxCocoa

final class RestaurantReviewListViewModel {
    
    private let disposeBag = DisposeBag()
    private let repository = ReviewRepository()
    let restaurant: Restaurant
    
    struct Input {}
    
    struct Output {
        let reviews: Driver<[Review]>
        let isEmpty: Driver<Bool>
    }
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }
    
    func transform(_ input: Input) -> Output {
        let reviews = repository.fetchReviewsByRestaurantId(restaurantId: restaurant.restaurantId)
            .map { reviews in
                reviews.sorted { $0.ateAt > $1.ateAt }
            }
            .asDriver(onErrorJustReturn: [])
        
        let isEmpty = reviews
            .map { $0.isEmpty }
        
        return Output(
            reviews: reviews,
            isEmpty: isEmpty
        )
    }
}
