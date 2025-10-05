//
//  RestaurantSearchViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RestaurantSearchViewController: BaseViewController {
    
    private let mainView = RestaurantSearchView()
    private let viewModel = RestaurantSearchViewModel()
    private let disposeBag = DisposeBag()
    
    // 식당 선택 콜백
    var onRestaurantSelected: ((RestaurantData) -> Void)?
    
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
        view.backgroundColor = .white
    }
    
    private func setupTableView() {
        mainView.tableView.register(RestaurantSearchCell.self, forCellReuseIdentifier: RestaurantSearchCell.identifier)
    }
    
    private func bind() {
        let input = RestaurantSearchViewModel.Input(
            searchButtonTapped: mainView.searchButton.rx.tap.asObservable(),
            searchText: mainView.searchTextField.rx.text.orEmpty.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 뒤로가기 버튼 처리
        mainView.backButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 검색 결과를 테이블뷰에 바인딩
        output.searchResults
            .drive(mainView.tableView.rx.items(
                cellIdentifier: RestaurantSearchCell.identifier,
                cellType: RestaurantSearchCell.self
            )) { row, restaurant, cell in
                cell.configure(with: restaurant)
            }
            .disposed(by: disposeBag)
        
        // 검색 결과 개수 표시
        output.searchResults
            .map { "검색 결과 \($0.count)개" }
            .drive(mainView.resultCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 검색 결과가 없을 때 테이블뷰 숨김
        output.searchResults
            .map { $0.isEmpty }
            .drive(mainView.tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.errorMessage
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] message in
                self?.showAlert(title: "오류", message: message)
            })
            .disposed(by: disposeBag)
        
        // 엔터키로 검색
        mainView.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(with: self) { owner, _ in
                owner.mainView.searchButton.sendActions(for: .touchUpInside)
            }
            .disposed(by: disposeBag)
        
        // 테이블뷰 셀 선택 처리
        mainView.tableView.rx.modelSelected(RestaurantData.self)
            .subscribe(with: self) { owner, restaurant in
                owner.onRestaurantSelected?(restaurant)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
