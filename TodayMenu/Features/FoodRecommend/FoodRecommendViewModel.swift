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
        let recommendButtonTap: Observable<Void>  // 추천 버튼 탭
        let passTap: Observable<Void>
        let acceptTap: Observable<Void>
        let reviewTap: Observable<Void>
    }
    struct Output {
        let currentItem: Driver<FoodRecommendation?>
        let isAccepted: Driver<Bool>
        let routeToReview: Signal<FoodRecommendation>
        let isLoading: Driver<Bool>
    }
    
    private let provider: RecommendationProvider
    private let recommendService = FoodRecommendService()
    private let foodRepository = FoodRepository()
    private let bag = DisposeBag()
    
    private let currentRecommendation = BehaviorRelay<FoodRecommendation?>(value: nil)
    private let accepted = BehaviorRelay<Bool>(value: false)
    private let routeRelay = PublishRelay<FoodRecommendation>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    
    init(provider: RecommendationProvider = RealmRecommendationProvider()) {
        self.provider = provider
    }
    
    func transform(_ input: Input) -> Output {
        
        // 추천 버튼 탭 → 추천 음식 로드
        input.recommendButtonTap
            .do(onNext: { [weak self] _ in
                self?.isLoadingRelay.accept(true)
                self?.accepted.accept(false) // 추천 받을 때마다 accept 상태 초기화
            })
            .flatMapLatest { [provider] _ in
                return provider.getRecommendation()
            }
            .do(onNext: { [weak self] recommendation in
                print("추천 결과: \(recommendation?.title ?? "nil")")
                self?.isLoadingRelay.accept(false)
            })
            .bind(to: currentRecommendation)
            .disposed(by: bag)
        
        // PASS → 스킵 이력 저장 + 다음 추천 로드
        input.passTap
            .withLatestFrom(currentRecommendation)
            .compactMap { $0 }
            .do(onNext: { [weak self] _ in
                print("PASS")
                self?.isLoadingRelay.accept(true)
                self?.accepted.accept(false) // pass할 때도 accept 상태 초기화
            })
            .flatMapLatest { [weak self, recommendService, foodRepository, provider] item -> Observable<FoodRecommendation?> in
                guard let self = self else { return .just(nil) }
                
                // category로 foodId 가져오기
                guard let foodId = foodRepository.getFoodId(for: item.category) else {
                    print("foodId를 찾을 수 없음: \(item.category)")
                    return provider.getRecommendation()
                }

                // Skip 이력 저장 후 바로 다음 추천
                return recommendService.saveRecommendHistory(foodId: foodId, isAccepted: false)
                    .flatMap { _ in
                        print("다음 추천 요청 중...")
                        return provider.getRecommendation()
                    }
            }
            .do(onNext: { [weak self] recommendation in
                self?.isLoadingRelay.accept(false)
            })
            .bind(to: currentRecommendation)
            .disposed(by: bag)
        
        // ACCEPT → 수락 이력 저장 + 버튼 상태 변경
        input.acceptTap
            .withLatestFrom(currentRecommendation)
            .compactMap { $0 }
            .flatMapLatest { [recommendService, foodRepository] item -> Observable<Void> in
                // category로 foodId 가져오기
                guard let foodId = foodRepository.getFoodId(for: item.category) else {
                    print("foodId를 찾을 수 없음: \(item.category)")
                    return .just(())
                }
                
                print("Accept 이력 저장: \(item.category) (foodId: \(foodId))")
                
                return recommendService.saveRecommendHistory(foodId: foodId, isAccepted: true)
                    .map { _ in () }
            }
            .map { true }
            .bind(to: accepted)
            .disposed(by: bag)
        
        // 리뷰 버튼 → 라우팅 신호 방출
        input.reviewTap
            .withLatestFrom(currentRecommendation)
            .compactMap { $0 }
            .bind(to: routeRelay)
            .disposed(by: bag)
        
        return Output(
            currentItem: currentRecommendation.asDriver(),
            isAccepted: accepted.asDriver(),
            routeToReview: routeRelay.asSignal(),
            isLoading: isLoadingRelay.asDriver()
        )
    }
}
