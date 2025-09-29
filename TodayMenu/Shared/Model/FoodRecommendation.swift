//
//  FoodRecommendation.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import Foundation

struct FoodRecommendation: Equatable {
    let emoji: String
    let title: String
    let place: String
    let distanceKm: Double
    let cuisine: String
    let category: String
}

protocol RecommendationProvider {
    func all() -> [FoodRecommendation]
}

final class MockRecommendationProvider: RecommendationProvider {
    func all() -> [FoodRecommendation] {
        return [
            .init(emoji: "🍖", title: "매운돈까스", place: "맛있는집", distanceKm: 0.8, cuisine: Cuisine.korean.rawValue, category: "돈까스"),
            .init(emoji: "🍜", title: "마라탕", place: "라화방", distanceKm: 1.2, cuisine: Cuisine.chinese.rawValue, category: "마라탕"),
            .init(emoji: "🍣", title: "모듬초밥", place: "스시나니", distanceKm: 0.5, cuisine: Cuisine.japanese.rawValue, category: "초밥"),
            .init(emoji: "🍕", title: "페페로니 피자", place: "피자마루", distanceKm: 2.4, cuisine: Cuisine.western.rawValue, category: "피자"),
        ]
    }
}
