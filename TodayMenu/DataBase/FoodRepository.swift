//
//  FoodRepository.swift
//  TodayMenu
//
//  Created by Claude on 10/4/25.
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

// MARK: - Food 생성 및 조회
extension FoodRepository {
    
    // category에 해당하는 Food 찾기 또는 생성
    func getOrCreateFood(name: String, cuisine: String, category: String) -> Food {
        // 같은 category를 가진 Food가 이미 있는지 확인
        if let existingFood = realm.objects(Food.self)
            .filter("category == %@", category)
            .first {
            // 같은 category가 있으면 해당 foodId 사용
            let food = Food(
                name: name,
                cuisine: cuisine,
                category: category,
                foodId: existingFood.foodId
            )
            return food
        } else {
            // 새로운 category면 새로운 foodId 생성
            let newFoodId = ObjectId.generate().stringValue
            let food = Food(
                name: name,
                cuisine: cuisine,
                category: category,
                foodId: newFoodId
            )
            return food
        }
    }
    
    // category로 foodId 조회
    func getFoodId(for category: String) -> String? {
        return realm.objects(Food.self)
            .filter("category == %@", category)
            .first?.foodId
    }
    
    // 모든 고유 category 목록 조회
    func getAllUniqueCategories() -> [String] {
        let allFoods = realm.objects(Food.self)
        let categories = Set(allFoods.map { $0.category })
        return Array(categories).sorted()
    }
    
    // 특정 foodId를 가진 모든 Food 조회
    func getFoods(by foodId: String) -> [Food] {
        let foods = realm.objects(Food.self)
            .filter("foodId == %@", foodId)
        return Array(foods)
    }
}

extension FoodRepository {
    
    // category에 해당하는 Food 찾기 또는 생성 (Observable)
    func getOrCreateFoodObservable(name: String, cuisine: String, category: String) -> Observable<Food> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "FoodRepository", code: -1))
                return Disposables.create()
            }
            
            let food = self.getOrCreateFood(name: name, cuisine: cuisine, category: category)
            observer.onNext(food)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
