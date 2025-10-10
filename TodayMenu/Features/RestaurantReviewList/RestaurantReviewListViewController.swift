//
//  RestaurantReviewListViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RestaurantReviewListViewController: BaseViewController {
    
    private let mainView = RestaurantReviewListView()
    private let viewModel: RestaurantReviewListViewModel
    private let disposeBag = DisposeBag()
    
    init(restaurant: Restaurant) {
        self.viewModel = RestaurantReviewListViewModel(restaurant: restaurant)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bind()
    }
    
    override func configureView() {
        super.configureView()
        title = "\(viewModel.restaurant.name) 리뷰 목록"
    }
    
    private func setupTableView() {
        mainView.tableView.register(ReviewForOneRestaurantTableViewCell.self, forCellReuseIdentifier: ReviewForOneRestaurantTableViewCell.identifier)
    }
    
    private func bind() {
        let input = RestaurantReviewListViewModel.Input()
        let output = viewModel.transform(input)
        
        output.reviews
            .drive(mainView.tableView.rx.items(
                cellIdentifier: ReviewForOneRestaurantTableViewCell.identifier,
                cellType: ReviewForOneRestaurantTableViewCell.self)) { index, review, cell in
                cell.configure(with: review)
            }
            .disposed(by: disposeBag)
        
        output.isEmpty
            .drive(with: self) { owner, isEmpty in
                owner.mainView.showEmptyState(isEmpty)
            }
            .disposed(by: disposeBag)
    }
}
