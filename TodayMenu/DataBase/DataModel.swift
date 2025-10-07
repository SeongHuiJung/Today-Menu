//
//  data.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import Foundation
import RealmSwift

class Review: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var food: List<FoodReview> // 메뉴 1:N
    @Persisted var restaurant: Restaurant? // 음식점 1:1
    @Persisted var rating: Double // 0.5 단위 평점
    @Persisted var comment: String? // 코멘트
    @Persisted var companion: List<Companion> // 함께 먹은 친구들 1:N
    @Persisted var photos: List<String> // 직접 찍은 사진 (파일 경로 또는 URL)
    @Persisted var ateAt: Date // 먹은 날짜/시간
    @Persisted var createdAt: Date // 데이터 생성 시각
    @Persisted var updatedAt: Date? // 수정 시각 (수정한 적 없으면 nil)
    @Persisted var averagePrice: Int? // 음식 평균 가격
    @Persisted var emoji: String? // 이모지 이름
    
    convenience init(food: [FoodReview], restaurant: Restaurant? = nil, rating: Double, comment: String? = nil, companion: [Companion] = [], photos: [String] = [], ateAt: Date, averagePrice: Int? = nil, emoji: String? = nil) {
        self.init()
        
        self.food.append(objectsIn: food)
        self.restaurant = restaurant
        self.rating = rating
        self.comment = comment
        self.companion.append(objectsIn: companion)
        self.photos.append(objectsIn: photos)
        self.ateAt = ateAt
        self.createdAt = Date()
        self.updatedAt = nil
        self.averagePrice = averagePrice
        self.emoji = emoji
    }
}

class FoodReview: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String // 음식 이름
    @Persisted var foodId: String // 음식 고유번호
    
    // Inverse Relationship
    @Persisted(originProperty: "food")
    var review: LinkingObjects<Review> // 리뷰 역참조
    
    convenience init(name: String, foodId: String) {
        self.init()
        
        self.name = name
        self.foodId = foodId
    }
}

class FoodType: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var cuisine: String // 메뉴 카테고리 대분류 (예: 한식, 중식, 일식)
    @Persisted var category: String // 메뉴 카테고리 중분류 (예: 피자, 돈까스, 초밥, 스테이크)
    @Persisted var foodId: String // 음식 고유번호 (category별 고유값)
    
    convenience init(cuisine: String, category: String, foodId: String) {
        self.init()
        
        self.cuisine = cuisine
        self.category = category
        self.foodId = foodId
    }
}

class RecommendHistory: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var foodId: String // 음식 고유번호 (FoodType의 foodId)
    @Persisted var isAccepted: Bool // 추천됐을때 accept 여부
    @Persisted var createdAt: Date // 생성 시각
    @Persisted var reviewId: String? // 작성된 Review 테이블의 id pk
    
    convenience init(foodId: String, isAccepted: Bool) {
        self.init()
        
        self.foodId = foodId
        self.isAccepted = isAccepted
        self.createdAt = Date()
        self.reviewId = nil
    }
}

class Restaurant: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String // 음식점 이름
    @Persisted var latitude: Double // 위도
    @Persisted var longitude: Double // 경도
    @Persisted var cuisine: String // 한중일 등 음식 카테고리
    @Persisted var restaurantId: String // 식당 고유번호
    
    // Inverse Relationship
    @Persisted(originProperty: "restaurant")
    var review: LinkingObjects<Review> // 리뷰 역참조
    
    convenience init(name: String, latitude: Double, longitude: Double, cuisine: String = "", restaurantId: String) {
        self.init()
        
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.cuisine = cuisine
        self.restaurantId = restaurantId
    }
}

class Companion: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var type: String // 동행인 타입 enum의 rawValue
    @Persisted var name: String? // 동행인 이름 (선택사항)
    
    // Inverse Relationship
    @Persisted(originProperty: "companion")
    var review: LinkingObjects<Review> // 함께 먹은 리뷰 역참조
    
    convenience init(type: CompanionType, name: String? = nil) {
        self.init()
        
        self.type = type.rawValue
        self.name = name
    }
}

enum CompanionType: String, CaseIterable {
    case alone, friend, family,  lover, colleague
    
    var displayName: String {
        switch self {
        case .alone: return "혼자"
        case .friend: return "친구"
        case .family: return "가족"
        case .lover: return "연인"
        case .colleague: return "동료"
        }
    }
}

enum Cuisine: String, CaseIterable {
    case korean, chinese, japanese, western, mexican, vietnamese, thai
    
    var displayName: String {
        switch self {
        case .korean: return "한식"
        case .chinese: return "중식"
        case .japanese: return "일식"
        case .western: return "양식"
        case .mexican: return "멕시코식"
        case .vietnamese: return "베트남식"
        case .thai: return "태국식"
        }
    }
}
