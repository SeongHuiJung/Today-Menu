//
//  FoodRecommendService.swift
//  TodayMenu
//
//  Created by 정성희 on 10/4/25.
//

import Foundation
import RealmSwift
import RxSwift

// MARK: - 추천 점수 계산 결과
struct FoodTypeScore {
    let foodType: FoodType
    let score: Int
}

final class FoodRecommendService {
    
    private let realm: Realm
    
    init() {
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - 메인 추천 로직
extension FoodRecommendService {
    
    /// 음식 추천 (무제한)
    func getRecommendedFood() -> Observable<FoodType?> {
        return Observable.create { [weak self] observer in
            guard let self else {
                print("FoodRecommendService: self가 nil")
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let allFoodTypes = Array(self.realm.objects(FoodType.self))
            print("전체 FoodType 개수: \(allFoodTypes.count)")
            
            // 1. FoodType이 없으면 nil 반환
            guard !allFoodTypes.isEmpty else {
                print("FoodType이 비어있음")
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 2. 각 FoodType의 점수 계산
            let scored = allFoodTypes.map { foodType -> FoodTypeScore in
                let score = self.calculateScore(for: foodType)
                print("\(foodType.category): \(score)점")
                return FoodTypeScore(foodType: foodType, score: score)
            }
            
            // 3. 가중치 기반 랜덤 선택
            let selected = self.weightedRandomSelection(from: scored)
            print("최종 추천: \(selected?.category ?? "추천 음식이 없습니다.") (\(scored.first(where: { $0.foodType.id == selected?.id })?.score ?? 0)점)")
            
            observer.onNext(selected)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    /// 추천 이력 저장 (accept/skip) - RecommendHistory id 반환
    func saveRecommendHistory(foodId: String, isAccepted: Bool) -> Observable<Result<ObjectId, Error>> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.onNext(.failure(NSError(domain: "FoodRecommendService", code: -1)))
                observer.onCompleted()
                return Disposables.create()
            }

            do {
                try self.realm.write {
                    // Skip(isAccepted: false) 저장 시, 동일한 foodId의 최신 Accept 레코드를 삭제
                    if !isAccepted {
                        let previousAccepted = self.realm.objects(RecommendHistory.self)
                            .filter("foodId == %@ AND isAccepted == true", foodId)
                            .sorted(byKeyPath: "createdAt", ascending: false)

                        if let latestAccepted = previousAccepted.first {
                            self.realm.delete(latestAccepted)
                        }
                    }

                    // 새로운 이력 저장
                    let history = RecommendHistory(foodId: foodId, isAccepted: isAccepted)
                    self.realm.add(history)
                    observer.onNext(.success(history.id))
                }
                observer.onCompleted()
            } catch {
                observer.onNext(.failure(error))
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }
}

// MARK: - 점수 계산 로직
extension FoodRecommendService {
    
    private func calculateScore(for foodType: FoodType) -> Int {
        var score = 100  // 기본 점수
        
        // 1. Accept/Skip 이력 점수 (-100 ~ +100)
        score += getAcceptSkipScore(for: foodType)
        
        // 2. 평균 평점 점수 (-50 ~ +50)
        score += getAverageRatingScore(for: foodType)
        
        // 3. 최근 섭취 점수 (-100 ~ +100)
        score += getRecentEatingScore(for: foodType)
        
        // 최소 점수 보장 (완전히 0이 되지 않도록)
        return max(score, 10)
    }
    
    /// Accept/Skip 이력 점수 (-100 ~ +100)
    private func getAcceptSkipScore(for foodType: FoodType) -> Int {
        let histories = realm.objects(RecommendHistory.self)
            .filter("foodId == %@", foodType.foodId)
        
        let acceptCount = histories.filter("isAccepted == true").count
        let skipCount = histories.filter("isAccepted == false").count
        
        // Accept는 +10점, Skip은 -15점
        let acceptScore = acceptCount * 10
        let skipPenalty = skipCount * -15
        
        let totalScore = acceptScore + skipPenalty
        
        // -100 ~ +100 범위로 제한
        return max(-100, min(100, totalScore))
    }
    
    /// 평균 평점 점수 (-50 ~ +50)
    private func getAverageRatingScore(for foodType: FoodType) -> Int {
        // 해당 foodId를 가진 모든 FoodReview 찾기
        let foodReviews = realm.objects(FoodReview.self)
            .filter("foodId == %@", foodType.foodId)
        
        // 모든 리뷰 수집
        var allReviews: [Review] = []
        for foodReview in foodReviews {
            allReviews.append(contentsOf: Array(foodReview.review))
        }
        
        guard !allReviews.isEmpty else {
            return 0  // 리뷰 없으면 중립
        }
        
        let avgRating = allReviews.map(\.rating).reduce(0, +) / Double(allReviews.count)
        
        // 평점에 따른 점수
        // 5.0점 = +50점, 4.0점 = +30점, 3.0점 = +10점, 2.0점 = -20점, 1.0점 = -50점
        if avgRating >= 4.5 {
            return 50
        } else if avgRating >= 4.0 {
            return 30
        } else if avgRating >= 3.5 {
            return 10
        } else if avgRating >= 3.0 {
            return 0
        } else if avgRating >= 2.0 {
            return -20
        } else {
            return -50
        }
    }
    
    /// 최근 섭취 점수 (-100 ~ +100)
    private func getRecentEatingScore(for foodType: FoodType) -> Int {
        // 해당 foodId를 가진 모든 FoodReview 찾기
        let foodReviews = realm.objects(FoodReview.self)
            .filter("foodId == %@", foodType.foodId)
        
        // 모든 리뷰의 ateAt 가져오기
        var allDates: [Date] = []
        for foodReview in foodReviews {
            let reviews = Array(foodReview.review)
            allDates.append(contentsOf: reviews.map { $0.ateAt })
        }
        
        guard let lastDate = allDates.max() else {
            return 100  // 한 번도 안 먹었으면 최대 점수
        }
        
        let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        
        // 안 먹은 기간에 따른 점수
        // 30일 이상 = +100점, 14일 = +50점, 7일 = 0점, 3일 이하 = -100점
        if daysSince >= 30 {
            return 100
        } else if daysSince >= 21 {
            return 80
        } else if daysSince >= 14 {
            return 50
        } else if daysSince >= 7 {
            return 0
        } else if daysSince >= 3 {
            return -50
        } else {
            return -100
        }
    }
    
    /// 가중치 기반 랜덤 선택
    /// 점수가 높을수록 선택될 확률이 높음
    private func weightedRandomSelection(from scored: [FoodTypeScore]) -> FoodType? {
        guard !scored.isEmpty else { return nil }
        
        // 모든 점수를 양수로 변환 (최소값을 0으로 만듦)
        let minScore = scored.map(\.score).min() ?? 0
        let offset = minScore < 0 ? abs(minScore) : 0
        
        let adjustedScored = scored.map { item in
            FoodTypeScore(foodType: item.foodType, score: item.score + offset)
        }
        
        // 전체 가중치 합계
        let totalWeight = adjustedScored.map(\.score).reduce(0, +)
        
        guard totalWeight > 0 else {
            // 모든 점수가 0이면 랜덤 선택
            return scored.randomElement()?.foodType
        }
        
        // 랜덤 값 생성 (0 ~ totalWeight)
        let randomValue = Int.random(in: 0..<totalWeight)
        
        // 누적 가중치로 선택
        var accumulated = 0
        for item in adjustedScored {
            accumulated += item.score
            if randomValue < accumulated {
                return item.foodType
            }
        }
        
        // fallback (혹시 모를 경우)
        return adjustedScored.last?.foodType
    }
}

// MARK: - 디버깅 및 테스트용 메서드
extension FoodRecommendService {

    /// 모든 음식의 점수 상세 정보 출력
    func printScoreDetails() {
        let allFoodTypes = Array(realm.objects(FoodType.self))

        print("\n========== 추천 점수 상세 분석 ==========")
        print("총 음식 개수: \(allFoodTypes.count)\n")

        for foodType in allFoodTypes.sorted(by: { $0.category < $1.category }) {
            let acceptSkipScore = getAcceptSkipScore(for: foodType)
            let ratingScore = getAverageRatingScore(for: foodType)
            let recentScore = getRecentEatingScore(for: foodType)
            let totalScore = 100 + acceptSkipScore + ratingScore + recentScore
            let finalScore = max(totalScore, 10)

            print("   \(foodType.category) (foodId: \(foodType.foodId))")
            print("   - Accept/Skip: \(acceptSkipScore >= 0 ? "+" : "")\(acceptSkipScore)점")
            print("   - 평균 평점: \(ratingScore >= 0 ? "+" : "")\(ratingScore)점")
            print("   - 최근 섭취: \(recentScore >= 0 ? "+" : "")\(recentScore)점")
            print("   - 최종 점수: \(finalScore)점\n")
        }

        print("==========================================\n")
    }

    /// 특정 음식의 점수 상세 정보 출력
    func printScoreDetails(for foodType: FoodType) {
        let acceptSkipScore = getAcceptSkipScore(for: foodType)
        let ratingScore = getAverageRatingScore(for: foodType)
        let recentScore = getRecentEatingScore(for: foodType)
        let totalScore = 100 + acceptSkipScore + ratingScore + recentScore
        let finalScore = max(totalScore, 10)

        // Accept/Skip 상세
        let histories = realm.objects(RecommendHistory.self).filter("foodId == %@", foodType.foodId)
        let acceptCount = histories.filter("isAccepted == true").count
        let skipCount = histories.filter("isAccepted == false").count

        // 평점 상세
        let foodReviews = realm.objects(FoodReview.self).filter("foodId == %@", foodType.foodId)
        var allReviews: [Review] = []
        for foodReview in foodReviews {
            allReviews.append(contentsOf: Array(foodReview.review))
        }
        let avgRating = allReviews.isEmpty ? 0.0 : allReviews.map(\.rating).reduce(0, +) / Double(allReviews.count)

        // 최근 섭취일 상세
        var allDates: [Date] = []
        for foodReview in foodReviews {
            let reviews = Array(foodReview.review)
            allDates.append(contentsOf: reviews.map { $0.ateAt })
        }
        let daysSince = allDates.max().map { Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0 } ?? -1

        print("\n========== \(foodType.category) 점수 상세 ==========")
        print(" FoodId: \(foodType.foodId)")
        print(" Accept/Skip 이력: \(acceptSkipScore >= 0 ? "+" : "")\(acceptSkipScore)점")
        print("   - Accept: \(acceptCount)회 (+\(acceptCount * 10)점)")
        print("   - Skip: \(skipCount)회 (\(skipCount * -15)점)")

        print(" 평균 평점: \(ratingScore >= 0 ? "+" : "")\(ratingScore)점")
        print("   - 총 리뷰: \(allReviews.count)개")
        print("   - 평균 평점: \(String(format: "%.1f", avgRating))")

        print(" 최근 섭취일: \(recentScore >= 0 ? "+" : "")\(recentScore)점")
        if daysSince >= 0 {
            print("   - 마지막 섭취: \(daysSince)일 전")
        } else {
            print("   - 마지막 섭취: 없음")
        }

        print(" 최종 점수: \(finalScore)점 (기본 100 + \(acceptSkipScore) + \(ratingScore) + \(recentScore))")
        print("==========================================\n")
    }
}
