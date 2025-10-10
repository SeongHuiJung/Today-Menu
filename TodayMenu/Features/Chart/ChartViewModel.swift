//
//  ChartViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ChartViewModel {

    private let disposeBag = DisposeBag()

    struct Input {
        let viewDidLoad: Observable<Void>
        let rotationAngle: Observable<CGFloat>
    }

    struct Output {
        let chartData: Driver<[ChartDataModel]>
        let currentRotation: Driver<CGFloat>
    }

    func transform(input: Input) -> Output {

        // 테스트 데이터 - 비율 기반 (10%, 30%, 55%, 5%)
        let chartData = input.viewDidLoad
            .map { [
                ChartDataModel(label: "1", percentage: 0.1),
                ChartDataModel(label: "2", percentage: 0.3),
                ChartDataModel(label: "3", percentage: 0.55),
                ChartDataModel(label: "4", percentage: 0.05)
            ] }
            .asDriver(onErrorJustReturn: [])

        let currentRotation = input.rotationAngle
            .asDriver(onErrorJustReturn: 0)

        return Output(
            chartData: chartData,
            currentRotation: currentRotation
        )
    }
}
