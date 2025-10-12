//
//  ChartViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ChartViewController: BaseViewController {

    private let viewModel = ChartViewModel()
    private let disposeBag = DisposeBag()

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let rotationAngleSubject = PublishSubject<CGFloat>()

    private let donutChartView: DonutChartView = {
        let view = DonutChartView()
        view.backgroundColor = .clear
        return view
    }()

    private let categoryListView: CategoryListView = {
        let view = CategoryListView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewDidLoadSubject.onNext(())
    }

    override func configureHierarchy() {
        view.addSubview(donutChartView)
        view.addSubview(categoryListView)
    }

    override func configureLayout() {
        donutChartView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }

        categoryListView.snp.makeConstraints { make in
            make.top.equalTo(donutChartView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
}

// MARK: - Bind
extension ChartViewController {
    private func bind() {
        let input = ChartViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            rotationAngle: rotationAngleSubject.asObservable(),
            selectedCuisine: donutChartView.selectedCuisine
        )

        let output = viewModel.transform(input: input)

        // 차트 데이터 바인딩
        output.categoryReviewChartData
            .drive(onNext: { [weak self] data in
                guard let self else { return }
                donutChartView.configure(with: data)
            })
            .disposed(by: disposeBag)

        // 카테고리 리스트 바인딩
        output.categoryBreakdown
            .drive(onNext: { [weak self] data in
                guard let self else { return }
                categoryListView.configure(with: data)
            })
            .disposed(by: disposeBag)
    }
}
