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
        let chartData: Driver<[String]>
        let currentRotation: Driver<CGFloat>
    }

    func transform(input: Input) -> Output {

        // 테스트 데이터
        let chartData = input.viewDidLoad
            .map { ["1", "2", "3", "4"] }
            .asDriver(onErrorJustReturn: [])

        let currentRotation = input.rotationAngle
            .asDriver(onErrorJustReturn: 0)

        return Output(
            chartData: chartData,
            currentRotation: currentRotation
        )
    }
}
