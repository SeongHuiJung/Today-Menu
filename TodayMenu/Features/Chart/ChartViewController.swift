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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        return view
    }()

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

        // 컨텐츠가 네비게이션 바 아래로 연장되도록 설정
        self.edgesForExtendedLayout = [.top, .left, .right, .bottom]
        self.extendedLayoutIncludesOpaqueBars = true

        configureNavigationBar()
        bind()
        viewDidLoadSubject.onNext(())
    }


    private func configureNavigationBar() {
        // 네비게이션 바를 반투명하게 설정
        navigationController?.navigationBar.isTranslucent = true

        // 블러 효과 설정
        let blur = UIBlurEffect(style: .systemMaterial)
        let appearance = UINavigationBarAppearance()

        // 완전 투명 베이스 + 블러 효과 적용
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = blur
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.05)

        // 그림자 제거
        appearance.shadowColor = .clear

        // 타이틀 스타일
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(donutChartView)
        contentView.addSubview(categoryListView)
    }

    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(0)
            make.leading.trailing.bottom.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        donutChartView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }

        categoryListView.snp.makeConstraints { make in
            make.top.equalTo(donutChartView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func configureView() {
        super.configureView()
        view.backgroundColor = .pointBackground2
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
                categoryListView.configure(data: data)
            })
            .disposed(by: disposeBag)
    }
}
