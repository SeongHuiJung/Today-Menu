//
//  RestaurantSearchViewController.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RestaurantSearchViewController: BaseViewController {
    
    private let mainView = RestaurantSearchView()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
    }
    
    override func configureView() {
        super.configureView()
        view.backgroundColor = .white
    }
    
    private func setupBackButton() {
        mainView.backButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
