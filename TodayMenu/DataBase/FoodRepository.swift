//
//  FoodRepository.swift
//  TodayMenu
//
//  Created by 정성희 on 10/4/25.
//

import Foundation
import RealmSwift
import RxSwift

final class FoodRepository {
    
    private let realm: Realm
    
    init() {
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - FoodType 관리
extension FoodRepository {
    
    /// category로 FoodType 찾기 또는 생성
    /// - Parameters:
    ///   - cuisine: 대분류 (한식, 중식 등)
    ///   - category: 중분류 (돈까스, 우동 등)
    /// - Returns: FoodType 객체
    func getOrCreateFoodType(cuisine: String, category: String) -> FoodType {
        // 1. 같은 category를 가진 FoodType이 이미 있는지 확인
        if let existingFoodType = realm.objects(FoodType.self)
            .filter("category == %@", category)
            .first {
            // 같은 category가 있으면 기존 객체 반환 (중복 생성 방지)
            return existingFoodType
        } else {
            // 새로운 category면 새로운 FoodType 생성
            let newFoodId = ObjectId.generate().stringValue
            let foodType = FoodType(
                cuisine: cuisine,
                category: category,
                foodId: newFoodId
            )
            
            // Realm에 저장
            do {
                try realm.write {
                    realm.add(foodType)
                }
            } catch {
                print("FoodType 저장 실패: \(error.localizedDescription)")
            }
            
            return foodType
        }
    }
    
    /// category로 foodId 조회
    func getFoodId(for category: String) -> String? {
        return realm.objects(FoodType.self)
            .filter("category == %@", category)
            .first?.foodId
    }
    
    /// 모든 고유 category 목록 조회
    func getAllCategories() -> [FoodType] {
        return Array(realm.objects(FoodType.self))
    }
    
    /// 특정 foodId를 가진 FoodType 조회
    func getFoodType(by foodId: String) -> FoodType? {
        return realm.objects(FoodType.self)
            .filter("foodId == %@", foodId)
            .first
    }
}

// MARK: - FoodReview 생성
extension FoodRepository {
    
    /// FoodReview 생성 (FoodType 자동 관리)
    func createFoodReview(name: String, cuisine: String, category: String) -> FoodReview {
        // FoodType 찾거나 생성
        let foodType = getOrCreateFoodType(cuisine: cuisine, category: category)
        
        // FoodReview 생성
        let foodReview = FoodReview(
            name: name,
            foodId: foodType.foodId
        )
        
        return foodReview
    }
}

extension FoodRepository {
    
    /// FoodReview 생성 (Observable)
    func createFoodReviewObservable(name: String, cuisine: String, category: String) -> Observable<FoodReview> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "FoodRepository", code: -1))
                return Disposables.create()
            }
            
            let foodReview = self.createFoodReview(name: name, cuisine: cuisine, category: category)
            observer.onNext(foodReview)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
