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

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewDidLoadSubject.onNext(())
    }

    override func configureHierarchy() {
        view.addSubview(donutChartView)
    }

    override func configureLayout() {
        donutChartView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(300)
        }
    }

    override func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "통계"
    }
}

// MARK: - Bind
extension ChartViewController {
    private func bind() {
        let input = ChartViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            rotationAngle: rotationAngleSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

        // 차트 데이터 바인딩
        output.categoryReviewChartData
            .drive(onNext: { [weak self] data in
                guard let self else { return }
                donutChartView.configure(with: data)
            })
            .disposed(by: disposeBag)
    }
}
