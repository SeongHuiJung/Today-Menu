//
//  FoodTypeInitializer.swift
//  TodayMenu
//
//  Created by 정성희 on 10/4/25.
//

import Foundation
import RealmSwift

final class FoodTypeInitializer {
    
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
    
    // 앱 실행 시 FoodType 데이터 동기화
    func initializeCategoryData() {
        do {
            let realm = try Realm()
            let existingFoodTypes = realm.objects(FoodType.self)

            // Realm에 저장된 category 목록 생성 (비교용)
            let existingCategories = Set(existingFoodTypes.map { $0.category })

            let foodRepository = FoodRepository()

            // categoryData의 모든 항목을 확인하여 없는 것만 추가
            for (cuisine, categories) in categoryData {
                for category in categories {
                    if !existingCategories.contains(category) {
                        let _ = foodRepository.getOrCreateFoodType(
                            cuisine: cuisine.rawValue,
                            category: category
                        )
                    }
                }
            }

            // 최초 실행 플래그 설정
            if !UserDefaultsManager.hasInitializedFoodTypes {
                UserDefaultsManager.hasInitializedFoodTypes = true
            }

        } catch {
            print("FoodType 동기화 실패: \(error.localizedDescription)")
        }
    }
}
