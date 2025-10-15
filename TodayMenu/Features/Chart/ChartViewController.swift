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

    private let chartView = ChartView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 컨텐츠가 네비게이션 바 아래로 연장되도록 설정
        self.edgesForExtendedLayout = [.top, .left, .right, .bottom]
        self.extendedLayoutIncludesOpaqueBars = true

        configureNavigationBar()
        setupScrollViewDelegate()
        bind()
        viewDidLoadSubject.onNext(())
    }

    override func configureHierarchy() {
        view.addSubview(chartView)
    }

    override func configureLayout() {
        chartView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func configureView() {
        super.configureView()
    }
}

// MARK: - Bind
extension ChartViewController {
    private func bind() {
        let input = ChartViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            rotationAngle: rotationAngleSubject.asObservable(),
            selectedCuisine: chartView.donutChartView.selectedCuisine
        )

        let output = viewModel.transform(input: input)

        // 차트 데이터 바인딩
        output.categoryReviewChartData
            .drive(onNext: { [weak self] data in
                guard let self else { return }
                chartView.donutChartView.configure(with: data)
            })
            .disposed(by: disposeBag)

        // 카테고리 리스트 바인딩
        output.categoryData
            .drive(onNext: { [weak self] data in
                guard let self else { return }
                chartView.categoryListView.configure(data: data)
            })
            .disposed(by: disposeBag)

        // cuisine 라벨 바인딩
        output.selectedCuisineDisplayName
            .drive(onNext: { [weak self] cuisineName in
                guard let self else { return }
                chartView.categoryListView.updateCuisineLabel(with: cuisineName)
            })
            .disposed(by: disposeBag)

        // 데이터 존재 여부에 따라 UI 업데이트
        output.hasData
            .drive(onNext: { [weak self] hasData in
                guard let self else { return }
                chartView.updateUIForDataState(hasData: hasData)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NavigationBar
extension ChartViewController {
    private func setupScrollViewDelegate() {
        chartView.scrollView.delegate = self
    }

    private func configureNavigationBar() {
        // 네비게이션 바를 반투명하게 설정
        navigationController?.navigationBar.isTranslucent = true

        // 블러 효과 설정
        let blur = UIBlurEffect(style: .systemMaterial)
        let appearance = UINavigationBarAppearance()

        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = blur
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.05)
        appearance.shadowColor = .clear

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance

        // 초기에는 네비게이션 바를 완전히 투명하게 설정
        navigationController?.navigationBar.alpha = 0
    }

    private func updateNavigationBarAlpha(for scrollView: UIScrollView) {
        // 스크롤 오프셋을 기준으로 투명도 계산
        let offset = scrollView.contentOffset.y
        let threshold: CGFloat = 100.0 // 이 값을 조절하여 페이드 인 속도 조절

        // 0에서 1 사이의 alpha 값 계산
        let alpha = min(max(offset / threshold, 0), 1)

        navigationController?.navigationBar.alpha = alpha
    }
}

// MARK: - UIScrollViewDelegate
extension ChartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarAlpha(for: scrollView)
    }
}
