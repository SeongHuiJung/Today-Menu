//
//  FoodRecommendViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import Foundation
import RxSwift
import RxCocoa

final class FoodRecommendViewModel {
    struct Input {
        let passTap: Observable<Void>
        let acceptTap: Observable<Void>
        let reviewTap: Observable<Void>
    }
    struct Output {
        let currentItem: Driver<FoodRecommendation>
        let isAccepted: Driver<Bool>
        let routeToReview: Signal<FoodRecommendation>
    }
    
    private let provider: RecommendationProvider
    private let bag = DisposeBag()
    
    private let items: [FoodRecommendation]
    private let index = BehaviorRelay<Int>(value: 0)
    private let accepted = BehaviorRelay<Bool>(value: false)
    private let routeRelay = PublishRelay<FoodRecommendation>()
    
    init(provider: RecommendationProvider = MockRecommendationProvider()) {
        self.provider = provider
        self.items = provider.all()
    }
    
    func transform(_ input: Input) -> Output {
        // 현재 아이템
        let current = index
            .map { [items] i in items[i % items.count] }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        // PASS → 다음 인덱스로
        input.passTap
            .withLatestFrom(accepted)
            .filter { !$0 }                 // 이미 수락했으면 PASS 금지(요구사항 상 필요 시 삭제)
            .withLatestFrom(index) { _, i in i }
            .map { [weak self] i -> Int in
                guard let self else { return i }
                return (i + 1) % self.items.count
            }
            .bind(to: index)
            .disposed(by: bag)
        
        // ACCEPT → 버튼 숨김 + 리뷰 버튼 표시
        input.acceptTap
            .map { true }
            .bind(to: accepted)
            .disposed(by: bag)
        
        // 리뷰 버튼 → 라우팅 신호 방출
        input.reviewTap
            .withLatestFrom(index)
            .map { [items] i in items[i % items.count] }
            .bind(to: routeRelay)
            .disposed(by: bag)
        
        return Output(
            currentItem: current,
            isAccepted: accepted.asDriver(),
            routeToReview: routeRelay.asSignal()
        )
    }
}
