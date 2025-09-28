//
//  FoodRecommendViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FoodRecommendViewController: BaseViewController {
    private let mainView = FoodRecommendView()
    private let viewModel = FoodRecommendViewModel()
    private let bag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
        title = "음식 추천"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        let input = FoodRecommendViewModel.Input(
            passTap: mainView.passButton.rx.tap.asObservable(),
            acceptTap: mainView.acceptButton.rx.tap.asObservable(),
            reviewTap: mainView.reviewButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input)
        
        output.currentItem
            .drive(with: self) { owner, item in
                owner.mainView.render(item)
            }
            .disposed(by: bag)
        
        output.isAccepted
            .drive(with: self) { owner, isAccepted in
                owner.mainView.showAcceptedUI(isAccepted)
            }
            .disposed(by: bag)
        
        output.routeToReview
            .emit(with: self) { owner, item in
                let reviewVC = MakeFoodReviewViewController(food: item)
                owner.navigationController?.pushViewController(reviewVC, animated: true)
            }
            .disposed(by: bag)
    }
}
