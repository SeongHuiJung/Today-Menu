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
        let selectedCuisine: Observable<String>
    }

    struct Output {
        let categoryReviewChartData: Driver<[DonutChartDataModel]>
        let currentRotation: Driver<CGFloat>
        let categoryBreakdown: Driver<[CategoryCellDataModel]>
    }

    func transform(input: Input) -> Output {

        // FoodReview 테이블의 대분류(cuisine) 칼럼을 기준으로 차트 생성
        let categoryReviewChartData = input.viewDidLoad
            .map { [weak self] _ -> [DonutChartDataModel] in
                guard let self = self else { return [] }
                return self.getCategoryReviewChartData()
            }
            .asDriver(onErrorJustReturn: [])

        let currentRotation = input.rotationAngle
            .asDriver(onErrorJustReturn: 0)

        // 선택된 cuisine에 따라 중분류(category) 데이터 생성
        let categoryBreakdown = input.selectedCuisine
            .map { [weak self] cuisine -> [CategoryCellDataModel] in
                guard let self = self else { return [] }
                return getCategoryDataByCuisine(cuisine: cuisine)
            }
            .asDriver(onErrorJustReturn: [])

        return Output(
            categoryReviewChartData: categoryReviewChartData,
            currentRotation: currentRotation,
            categoryBreakdown: categoryBreakdown
        )
    }

    private func getCategoryReviewChartData() -> [DonutChartDataModel] {
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

            // 비율계산하여 DonutChartDataModel 배열 생성
            let chartData = cuisineCount.map { cuisine, count in
                let percentage = Double(count) / Double(totalCount)
                let displayName = Cuisine(rawValue: cuisine)?.displayName ?? cuisine
                return DonutChartDataModel(label: displayName, percentage: percentage, rawValue: cuisine)
            }
            .sorted { $0.percentage > $1.percentage } // 비율이 큰 순서대로 정렬

            return chartData

        } catch {
            print("Realm 오류: \(error.localizedDescription)")
            return []
        }
    }

    private func getCategoryDataByCuisine(cuisine: String) -> [CategoryCellDataModel] {
        do {
            let realm = try Realm()
            let allFoodReviews = realm.objects(FoodReview.self)

            // 선택된 cuisine에 해당하는 FoodReview 만 필터링
            var categoryCount: [String: Int] = [:]

            for foodReview in allFoodReviews {
                if let foodType = foodRepository.getFoodType(by: foodReview.foodId) {
                    // 선택된 cuisine과 일치하는지 확인
                    if foodType.cuisine == cuisine {
                        let category = foodType.category
                        categoryCount[category, default: 0] += 1
                    }
                }
            }

            // 데이터가 없으면 빈 배열 반환
            guard !categoryCount.isEmpty else {
                return []
            }

            // 해당 cuisine의 총 개수 계산
            let totalCount = categoryCount.values.reduce(0, +)

            // CategoryCellDataModel 배열 생성
            let categoryData = categoryCount.map { category, count in
                let percentage = Double(count) / Double(totalCount)
                return CategoryCellDataModel(
                    name: category,
                    percentage: percentage,
                    count: count
                )
            }
            .sorted { $0.count > $1.count } // 개수가 많은 순서대로 정렬

            return categoryData

        } catch {
            print("Realm 오류: \(error.localizedDescription)")
            return []
        }
    }
}
