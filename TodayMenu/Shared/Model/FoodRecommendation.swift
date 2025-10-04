//
//  FoodRecommendation.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import Foundation
import RealmSwift
import RxSwift

struct FoodRecommendation: Equatable {
    let emoji: String?
    let title: String
    let cuisine: String
    let category: String
}

protocol RecommendationProvider {
    func getRecommendation() -> Observable<FoodRecommendation?>
}

final class RealmRecommendationProvider: RecommendationProvider {
    private let service = FoodRecommendService()
    
    func getRecommendation() -> Observable<FoodRecommendation?> {
        return service.getRecommendedFood()
            .map { foodType -> FoodRecommendation? in
                guard let foodType = foodType else { return nil }
                return FoodRecommendation(
                    emoji: nil,
                    title: foodType.category,
                    cuisine: foodType.cuisine,
                    category: foodType.category
                )
            }
    }
}

//final class MockRecommendationProvider: RecommendationProvider {
//    func getRecommendation() -> Observable<FoodRecommendation?> {
//        let mock = FoodRecommendation(
//            emoji: "🍖",
//            title: "매운돈까스",
//            cuisine: Cuisine.korean.rawValue,
//            category: "돈까스"
//        )
//        return Observable.just(mock)
//    }
//}
