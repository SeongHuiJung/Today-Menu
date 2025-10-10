//
//  MockDataGenerator.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import Foundation
import RealmSwift

final class MockDataGenerator {
    
    static func generateSeptemberMockData() {
        let reviewRepository = ReviewRepository()
        let foodRepository = FoodRepository()
        
        let mockReviews: [(day: Int, foodName: String, restaurantName: String, rating: Double, comment: String?, companion: CompanionType, companionName: String?, cuisine: String, category: String, restaurantId: String, photoName: String?)] = [
            (1, "고기국수", "제주국수", 4.5, "깔끔한 육수가 일품", .friend, "지현", "한식", "국수", "hanoi_morning_001", "photo1"),
            (3, "짬뽕", "사대천왕 짬뽕", 4.0, "양도 많고 맛있다", .colleague, nil, "중식", "짬뽕", "army_stew_002", "photo2"),
            (5, "닭꼬치", "이자카야 하루", 4.8, "야끼토리 최고!", .friend, "민수", "일식", "구이", "izakaya_haru_003", "photo3"),
            (7, "함박스테이크", "스테이크하우스 본", 4.3, "소스가 진짜 맛있던 식당", .lover, nil, "양식", "스테이크", "steak_bon_004", "photo4"),
            (9, "마제소바", "면옥 타이베이", 4.6, "엄청 고소해서 좋았다", .alone, nil, "일식", "면", "mazesoba_taipei_005", "photo5"),
            (11, "마파두부", "두부의 정석", 4.2, "두부가 부드럽고 양이 많아서 좋았다", .family, nil, "중식", "마파두부", "tofu_seoul_006", "photo6"),
            (14, "샐러드", "샐러디 강남점", 4.0, "다이어트 제격용", .colleague, "수진", "샐러드", "샐러드", "salady_gangnam_007", "photo7"),
            (16, "닭갈비", "춘천 원조 닭갈비", 4.7, "많이 맵지 않아서 좋았다", .friend, "태훈", "한식", "닭갈비", "jinmi_rest_008", "photo8"),
            (19, "초밥", "스시야마", 4.9, "신선도 최고", .family, nil, "일식", "초밥", "sushi_yama_009", "photo9"),
            (22, "수제버거", "버거플래닛", 4.4, "패티에 육즙이 많아서 맛있었다", .friend, "현우", "양식", "버거", "burger_planet_010", "photo10"),
            //(2, "김치찌개", "명동김치찌개", 4.1, "집밥 같은 맛", .alone, nil, "한식", "찌개", "kimchi_myeongdong_011", nil),
            (4, "라멘", "이치란 홍대점", 4.5, "진한 돈코츠 국물", .friend, "서연", "일식", "국수", "ichiran_hongdae_012", nil),
           // (6, "파스타", "파스타베네", 4.0, "깔끔한 알리오올리오", .lover, nil, "양식", "파스타", "pasta_bene_013", nil),
            (8, "쭈꾸미볶음", "강남쭈꾸미", 4.3, "매콤해서 좋았다", .colleague, nil, "한식", "볶음", "jjukkumi_gangnam_014", nil),
            (10, "돈카츠", "사보텐", 4.2, "바삭한 튀김옷", .alone, nil, "일식", "튀김", "saboten_015", nil),
            (13, "제육볶음", "옛날제육", 4.6, "밥도둑", .friend, "준호", "한식", "볶음", "jeyuk_old_016", nil),
            (15, "피자", "피자헛 강남점", 3.8, "치즈가 많고 진짜 치즈여서 더 먹게된다", .family, nil, "양식", "피자", "pizzahut_gangnam_017", nil),
            (18, "냉면", "평양면옥", 4.7, "시원한 육수", .colleague, "은지", "한식", "면", "pyongyang_myeonok_018", nil),
            (21, "마라탕", "천진반점", 4.4, "얼얼하게 맛있음", .friend, "소희", "중식", "탕", "tianjin_rest_019", nil),
            (25, "비빔밥", "전주비빔밥", 4.5, "나물이 신선했다", .alone, nil, "한식", "밥", "jeonju_bibimbap_020", nil)
        ]
        
        // 9월 각 날짜에 데이터 생성
        let calendar = Calendar.current
        let year = 2025
        let month = 9
        
        for mockData in mockReviews {
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: mockData.day, hour: 12, minute: 0)) else {
                continue
            }
            
            // FoodRepository를 사용하여 FoodReview 생성
            let foodReview = foodRepository.createFoodReview(
                name: mockData.foodName,
                cuisine: mockData.cuisine,
                category: mockData.category
            )
            
            // Restaurant 생성
            let restaurant = Restaurant(
                name: mockData.restaurantName,
                latitude: 37.5665 + Double.random(in: -0.05...0.05),
                longitude: 126.9780 + Double.random(in: -0.05...0.05),
                cuisine: mockData.cuisine,
                restaurantId: mockData.restaurantId
            )
            
            // Companion 생성
            let companion = Companion(type: mockData.companion, name: mockData.companionName)
            
            // Photo 처리
            var photos: [String] = []
            if let photoName = mockData.photoName {
                let photoPath = "Picture/\(photoName)"
                photos.append(photoPath)
            }
            
            // Review 생성
            let review = Review(
                food: [foodReview],
                restaurant: restaurant,
                rating: mockData.rating,
                comment: mockData.comment,
                companion: [companion],
                photos: photos,
                ateAt: date,
                emoji: nil
            )
            
            // 저장
            _ = reviewRepository.saveReview(review)
                .subscribe(onNext: { result in
                    switch result {
                    case .success:
                        print("Mock 데이터 저장 성공: \(mockData.foodName) - \(mockData.day)일 (category: \(mockData.category), foodId: \(foodReview.foodId))")
                    case .failure(let error):
                        print("Mock 데이터 저장 실패: \(error.localizedDescription)")
                    }
                })
        }
    }
    
    static func clearAllData() {
        let repository = ReviewRepository()
        
        _ = repository.fetchAllReviews()
            .subscribe(onNext: { reviews in
                for review in reviews {
                    _ = repository.deleteReview(review).subscribe()
                }
                print("모든 데이터 삭제 완료")
            })
    }
    
    static func clearRecommendHistory() {
        do {
            let realm = try Realm()
            let histories = realm.objects(RecommendHistory.self)
            let count = histories.count
            try realm.write {
                realm.delete(histories)
            }
            print("RecommendHistory 삭제 완료: \(count)개")
        } catch {
            print("RecommendHistory 삭제 실패: \(error)")
        }
    }

    // MARK: - 추천 알고리즘 테스트용 메서드

    /// 특정 음식에 Accept 이력 추가
    static func addAcceptHistory(foodId: String, count: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                for _ in 0..<count {
                    let history = RecommendHistory(foodId: foodId, isAccepted: true)
                    realm.add(history)
                }
            }
            print("Accept 이력 추가: \(foodId) x\(count)")
        } catch {
            print("Accept 이력 추가 실패: \(error)")
        }
    }

    /// 특정 음식에 Skip 이력 추가
    static func addSkipHistory(foodId: String, count: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                for _ in 0..<count {
                    let history = RecommendHistory(foodId: foodId, isAccepted: false)
                    realm.add(history)
                }
            }
            print("Skip 이력 추가: \(foodId) x\(count)")
        } catch {
            print("Skip 이력 추가 실패: \(error)")
        }
    }

    /// 특정 음식의 최근 섭취일 조정 (daysAgo: 며칠 전)
    static func setLastEatingDate(foodName: String, daysAgo: Int) {
        let foodRepository = FoodRepository()
        let reviewRepository = ReviewRepository()

        // FoodReview 찾기
        guard let foodReview = foodRepository.getFoodReviewByName(foodName) else {
            print("음식을 찾을 수 없음: \(foodName)")
            return
        }

        // FoodType 찾기
        guard let foodType = foodRepository.getFoodType(by: foodReview.foodId) else {
            print("FoodType을 찾을 수 없음: foodId=\(foodReview.foodId)")
            return
        }

        let targetDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!

        // 해당 음식의 리뷰 추가
        let restaurant = Restaurant(
            name: "테스트 식당",
            latitude: 37.5665,
            longitude: 126.9780,
            cuisine: foodType.cuisine,
            restaurantId: "test_\(UUID().uuidString)"
        )

        let companion = Companion(type: .alone, name: nil)

        let review = Review(
            food: [foodReview],
            restaurant: restaurant,
            rating: 3.0,
            comment: "테스트용 리뷰",
            companion: [companion],
            photos: [],
            ateAt: targetDate,
            emoji: nil
        )

        _ = reviewRepository.saveReview(review)
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    print("최근 섭취일 설정: \(foodName) - \(daysAgo)일 전")
                case .failure(let error):
                    print("최근 섭취일 설정 실패: \(error)")
                }
            })
    }

    /// 특정 음식에 평점 리뷰 추가
    static func addRatingReview(foodName: String, rating: Double, count: Int) {
        let foodRepository = FoodRepository()
        let reviewRepository = ReviewRepository()

        guard let foodReview = foodRepository.getFoodReviewByName(foodName) else {
            print("음식을 찾을 수 없음: \(foodName)")
            return
        }

        // FoodType 찾기 (foodId로)
        guard let foodType = foodRepository.getFoodType(by: foodReview.foodId) else {
            print("FoodType을 찾을 수 없음: foodId=\(foodReview.foodId)")
            return
        }

        for i in 0..<count {
            let restaurant = Restaurant(
                name: "테스트 식당 \(i+1)",
                latitude: 37.5665,
                longitude: 126.9780,
                cuisine: foodType.cuisine,
                restaurantId: "test_rating_\(UUID().uuidString)"
            )

            let companion = Companion(type: .alone, name: nil)
            let date = Calendar.current.date(byAdding: .day, value: -(30 + i), to: Date())!

            let review = Review(
                food: [foodReview],
                restaurant: restaurant,
                rating: rating,
                comment: "평점 테스트용 리뷰",
                companion: [companion],
                photos: [],
                ateAt: date,
                emoji: nil
            )

            _ = reviewRepository.saveReview(review)
                .subscribe(onNext: { result in
                    switch result {
                    case .success:
                        print("평점 리뷰 추가: \(foodName) - \(rating)")
                    case .failure(let error):
                        print("평점 리뷰 추가 실패: \(error)")
                    }
                })
        }
    }

    /// 추천 점수 상세 출력
    static func printRecommendScoreDetails() {
        let service = FoodRecommendService()
        service.printScoreDetails()
    }
}
