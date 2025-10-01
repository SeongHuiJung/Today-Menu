//
//  MockDataGenerator.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import Foundation
import RealmSwift

final class MockDataGenerator {
    
    static func generateSeptemberMockData() {
        let repository = ReviewRepository()
        
        // 9월 Mock 데이터
        let mockReviews: [(day: Int, foodName: String, restaurantName: String, rating: Double, comment: String?, companion: CompanionType, companionName: String?, cuisine: String, category: String, restaurantId: String)] = [
            (16, "비빔밥", "한옥마을", 4.5, "도우가 정말 쫄깃하고 치즈가 진짜 맛있어요!", .alone, nil, "한식", "비빔밥", "rest001"),
            (17, "라멘", "라멘야", 4.0, "국물이 진하고 면발이 쫄깃해요", .friend, "철수", "일식", "라멘", "rest002"),
            (18, "피자", "피자헛", 3.5, "치즈가 많아서 좋았어요", .family, nil, "양식", "피자", "rest003")
//            (15, "짬뽕", "가나디의 짬뽕", 5.0, "해물이 신선하고 국물이 칼칼해요!", .friend, "영희", "중식", "짬뽕", "rest004"),
//            (18, "스테이크", "스테이크 하우스", 4.5, "고기가 부드럽고 맛있어요", .lover, "사랑", "양식", "스테이크", "rest005"),
//            (20, "초밥", "스시로", 4.0, "신선한 회와 맛있는 초밥", .colleague, nil, "일식", "초밥", "rest006"),
//            (20, "된장찌개", "한옥마을", 4.5, "구수하고 맛있어요", .family, nil, "한식", "찌개", "rest001"),
//            (25, "파스타", "이탈리안 레스토랑", 4.0, "크림 소스가 부드러워요", .lover, "사랑", "양식", "파스타", "rest007"),
//            (28, "버거", "버거킹", 3.5, "패티가 두툼하고 맛있어요", .friend, "민수", "양식", "햄버거", "rest008"),
//            (1, "김치찌개", "맛있는집", 4.5, "김치가 잘 익어서 맛있어요", .alone, nil, "한식", "찌개", "rest009"),
//            (3, "돈까스", "돈까스 전문점", 4.0, "바삭하고 고소해요", .friend, "지수", "일식", "돈까스", "rest010"),
//            (10, "냉면", "평양냉면", 4.5, "시원하고 상큼해요", .family, nil, "한식", "냉면", "rest011"),
//            (13, "짜장면", "중국집", 3.5, "달달하고 맛있어요", .colleague, nil, "중식", "짜장면", "rest012"),
//            (16, "탕수육", "중국집", 4.0, "바삭하고 소스가 맛있어요", .friend, "현우", "중식", "탕수육", "rest012"),
//            (19, "샐러드", "샐러드 바", 4.0, "신선하고 건강한 맛", .alone, nil, "양식", "샐러드", "rest013"),
//            (22, "떡볶이", "떡볶이 맛집", 4.5, "매콤달콤 완벽해요", .friend, "수지", "한식", "분식", "rest014"),
//            (24, "회덮밥", "횟집", 4.5, "회가 신선하고 야채도 많아요", .lover, "사랑", "일식", "회덮밥", "rest015"),
//            (27, "갈비찜", "한정식집", 5.0, "고기가 부드럽고 양념이 최고예요!", .family, nil, "한식", "갈비찜", "rest016"),
//            (29, "쌀국수", "베트남 음식점", 4.0, "국물이 깔끔하고 맛있어요", .colleague, nil, "베트남식", "쌀국수", "rest017"),
//            (30, "치킨", "BBQ", 4.5, "바삭하고 양념이 맛있어요", .friend, "태희", "한식", "치킨", "rest018")
        ]
        
        // 9월 각 날짜에 데이터 생성
        let calendar = Calendar.current
        let year = 2025
        let month = 9
        
        for mockData in mockReviews {
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: mockData.day, hour: 12, minute: 0)) else {
                continue
            }
            
            // Food 생성
            let food = Food(name: mockData.foodName, cuisine: mockData.cuisine, category: mockData.category)
            
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
            
            // Review 생성
            let review = Review(
                food: [food],
                restaurant: restaurant,
                rating: mockData.rating,
                comment: mockData.comment,
                companion: [companion],
                photos: [],
                ateAt: date,
                averagePrice: Int.random(in: 8000...25000),
                emoji: nil
            )
            
            // 저장
            _ = repository.saveReview(review)
                .subscribe(onNext: { result in
                    switch result {
                    case .success:
                        print("✅ Mock 데이터 저장 성공: \(mockData.foodName) - \(mockData.day)일")
                    case .failure(let error):
                        print("❌ Mock 데이터 저장 실패: \(error.localizedDescription)")
                    }
                })
        }
        
        print("🎉 9월 Mock 데이터 20개 생성 완료!")
    }
    
    static func clearAllData() {
        let repository = ReviewRepository()
        
        _ = repository.fetchAllReviews()
            .subscribe(onNext: { reviews in
                for review in reviews {
                    _ = repository.deleteReview(review).subscribe()
                }
                print("🗑️ 모든 데이터 삭제 완료")
            })
    }
}
