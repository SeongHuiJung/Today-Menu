//
//  FoodRecommendViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

final class FoodRecommendViewController: BaseViewController {
    
    let realm = try! Realm()
    private let mainView = FoodRecommendView()
    private let viewModel = FoodRecommendViewModel()
    private let bag = DisposeBag()
    private let menuSelectedTime = Date() // 메뉴 선택 시간 저장
    
    override func loadView() {
        self.view = mainView
        title = "음식 추천"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        print(realm.configuration.fileURL)
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
                let reviewVC = MakeFoodReviewViewController(food: item, menuSelectedTime: owner.menuSelectedTime)
                reviewVC.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(reviewVC, animated: true)
            }
            .disposed(by: bag)
    }
}
