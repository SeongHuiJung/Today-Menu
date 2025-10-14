//
//  ChartView.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ChartView: BaseView {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        return view
    }()

    let donutChartView: DonutChartView = {
        let view = DonutChartView()
        view.backgroundColor = .clear
        return view
    }()

    let categoryListView: CategoryListView = {
        let view = CategoryListView()
        return view
    }()

    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(donutChartView)
        contentView.addSubview(categoryListView)
    }

    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
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
        backgroundColor = .pointBackground2
    }
}
