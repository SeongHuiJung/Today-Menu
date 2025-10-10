//
//  FoodTypeInitializer.swift
//  TodayMenu
//
//  Created by 정성희 on 10/4/25.
//

import Foundation
import RealmSwift

final class FoodTypeInitializer {
    
    // 앱 최초 실행 시 기본 FoodType 데이터 생성
    static func initializeIfNeeded() {
        // 이미 초기화했는지 확인
        let hasInitialized = UserDefaultsManager.hasInitializedFoodTypes
        
        if hasInitialized {
            print("FoodType 이미 초기화됨")
            return
        }
        
        // 초기화 시작
        createInitialFoodTypes()
        
        // 초기화 완료 플래그 저장
        UserDefaultsManager.hasInitializedFoodTypes = true
        print("FoodType 초기 데이터 생성 완료")
    }
    static let shared = FoodTypeInitializer()
    
    let categoryData: [Cuisine: [String]] = [
        .korean: [
            "비빔밥", "김치찌개", "불고기", "냉면", "삼겹살", "떡볶이", "육회", "김밥",
            "제육덮밥", "감자탕", "닭볶음탕", "된장찌개", "라면", "부대찌개",
            "국수", "닭갈비", "보쌈", "조개구이", "생선구이", "국밥"
        ],
        .chinese: [
            "짜장면", "짬뽕", "탕수육", "마라탕", "마라샹궈", "딤섬", "마파두부"
        ],
        .japanese: [
            "라멘", "초밥", "돈까스", "우동", "가츠동", "나베", "회", "소바", "텐동", "샤브샤브"
        ],
        .western: [
            "피자", "파스타", "스테이크", "햄버거", "리조또", "브런치", "샌드위치", "오므라이스"
        ],
        .asian: [
            "타코", "퀘사디아", "부리또", "쌀국수", "반미", "분짜", "반쎄오", "팟타이", "뿌팟퐁커리", "똠얌꿍", "나시고랭"
        ]
    ]
    
    // 강제로 초기화 (테스트용)
    static func forceInitialize() {
        print("FoodType 강제 초기화")
        
        // 기존 FoodType 삭제
    // 앱 실행 시 FoodType 데이터 동기화
    func initializeCategoryData() {
        do {
            let realm = try Realm()
            let existingFoodTypes = realm.objects(FoodType.self)
            try realm.write {
                realm.delete(existingFoodTypes)
            }
            print("기존 FoodType \(existingFoodTypes.count)개 삭제")
        } catch {
            print("FoodType 삭제 실패: \(error)")
        }
        
        // 새로 생성
        createInitialFoodTypes()
        
        // 플래그 업데이트
        UserDefaultsManager.hasInitializedFoodTypes = true
        print("FoodType 강제 초기화 완료")
    }
    
    /// 초기화 상태 리셋 (테스트용)
    static func resetInitializationFlag() {
        UserDefaultsManager.hasInitializedFoodTypes = false
        print("초기화 플래그 리셋")
    }
}

// MARK: - 초기 데이터 생성
extension FoodTypeInitializer {
    
    private static func createInitialFoodTypes() {
        let foodRepository = FoodRepository()
        
        // 초기 FoodType 데이터 (20개)
        let initialFoodTypes: [(cuisine: String, category: String)] = [
            // 한식
            (Cuisine.korean.rawValue, "비빔밥"),
            (Cuisine.korean.rawValue, "김치찌개"),
            (Cuisine.korean.rawValue, "불고기"),
            (Cuisine.korean.rawValue, "냉면"),
            (Cuisine.korean.rawValue, "삼겹살"),
            (Cuisine.korean.rawValue, "떡볶이"),
            (Cuisine.korean.rawValue, "육회"),
            (Cuisine.korean.rawValue, "김밥"),
            
            // 중식
            (Cuisine.chinese.rawValue, "짜장면"),
            (Cuisine.chinese.rawValue, "짬뽕"),
            (Cuisine.chinese.rawValue, "탕수육"),
            (Cuisine.chinese.rawValue, "마라탕"),
            (Cuisine.chinese.rawValue, "마라샹궈"),
            
            // 일식
            (Cuisine.japanese.rawValue, "라멘"),
            (Cuisine.japanese.rawValue, "초밥"),
            (Cuisine.japanese.rawValue, "돈까스"),
            (Cuisine.japanese.rawValue, "우동"),
            
            // 양식
            (Cuisine.western.rawValue, "피자"),
            (Cuisine.western.rawValue, "파스타"),
            (Cuisine.western.rawValue, "스테이크"),
            
            // 멕시코식
            (Cuisine.mexican.rawValue, "타코"),
            
            // 베트남식
            (Cuisine.vietnamese.rawValue, "쌀국수"),
            (Cuisine.vietnamese.rawValue, "반미"),
            
            // 태국식
            (Cuisine.thai.rawValue, "팟타이")
        ]

        for (cuisine, category) in initialFoodTypes {
            let _ = foodRepository.getOrCreateFoodType(
                cuisine: cuisine,
                category: category
            )
        }
    }
}

// MARK: - 유틸리티
extension FoodTypeInitializer {
    
    /// 현재 FoodType 개수 확인
    static func printCurrentFoodTypes() {
        do {
            let realm = try Realm()
            let foodTypes = realm.objects(FoodType.self)
            
            print("현재 FoodType 개수: \(foodTypes.count)")
            
            let groupedByCuisine = Dictionary(grouping: Array(foodTypes)) { $0.cuisine }
            
            for (cuisine, types) in groupedByCuisine.sorted(by: { $0.key < $1.key }) {
                print("\n[\(cuisine)] (\(types.count)개)")
                for type in types.sorted(by: { $0.category < $1.category }) {
                    print("   - \(type.category) (foodId: \(type.foodId))")
                }
            }
        } catch {
            print("Realm 읽기 실패: \(error)")
        }
    }
}
