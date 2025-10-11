//
//  ChartViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class ChartViewModel {

    private let disposeBag = DisposeBag()
    private let foodRepository = FoodRepository()

    struct Input {
        let viewDidLoad: Observable<Void>
        let rotationAngle: Observable<CGFloat>
    }

    struct Output {
        let categoryReviewChartData: Driver<[ChartDataModel]>
        let currentRotation: Driver<CGFloat>
    }

    func transform(input: Input) -> Output {

        // FoodReview 테이블의 대분류(cuisine) 칼럼을 기준으로 차트 생성
        let categoryReviewChartData = input.viewDidLoad
            .map { [weak self] _ -> [ChartDataModel] in
                guard let self = self else { return [] }
                return self.generateCategoryReviewChartData()
            }
            .asDriver(onErrorJustReturn: [])

        let currentRotation = input.rotationAngle
            .asDriver(onErrorJustReturn: 0)

        return Output(
            categoryReviewChartData: categoryReviewChartData,
            currentRotation: currentRotation
        )
    }

    private func generateCategoryReviewChartData() -> [ChartDataModel] {
        do {
            let realm = try Realm()
            let allFoodReviews = realm.objects(FoodReview.self)

            // foodId로 FoodType을 조회하여 cuisine별로 그룹핑
            var cuisineCount: [String: Int] = [:]

            for foodReview in allFoodReviews {
                if let foodType = foodRepository.getFoodType(by: foodReview.foodId) {
                    let cuisine = foodType.cuisine
                    cuisineCount[cuisine, default: 0] += 1
                }
            }

            // 데이터가 없으면 빈 배열 반환
            guard !cuisineCount.isEmpty else {
                return []
            }

            // 총 개수 계산
            let totalCount = cuisineCount.values.reduce(0, +)

            // 비율계산하여 ChartDataModel 배열 생성
            let chartData = cuisineCount.map { cuisine, count in
                let percentage = Double(count) / Double(totalCount)
                let displayName = Cuisine(rawValue: cuisine)?.displayName ?? cuisine
                return ChartDataModel(label: displayName, percentage: percentage)
            }
            .sorted { $0.percentage > $1.percentage } // 비율이 큰 순서대로 정렬

            return chartData

        } catch {
            print("Realm 오류: \(error.localizedDescription)")
            return []
        }
    }
}
