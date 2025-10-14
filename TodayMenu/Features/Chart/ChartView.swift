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
    
    let headerPadding: UIView = {
        let view = UIView()
        view.backgroundColor = .pointBackground0
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()
    
    let headerLabel = BasicLabel(text: "모모찌가 분석한\n음식 리포트에요!", alignment: .left, size: 20, weight: .bold, textColor: .fontPoint0)

    let characterImage = UIImageView(image: UIImage(named: "logoCharacter"))
    
    private let categoryReviewLabel = {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20))
        label.textColor = .fontPoint0
        label.backgroundColor = .pointBackground1
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.text = "카테고리별 리뷰"
        return label
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
        [headerPadding, characterImage, categoryReviewLabel, donutChartView, categoryListView].forEach { contentView.addSubview($0) }
        headerPadding.addSubview(headerLabel)
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
        
        headerPadding.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.horizontalEdges.equalToSuperview().inset(24)
        }

        headerLabel.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview().inset(16)
        }
        
        characterImage.snp.makeConstraints { make in
            make.bottom.equalTo(headerPadding.snp.bottom)
            make.right.equalTo(headerPadding.snp.right).offset(-15)
            make.size.equalTo(153)
        }
        
        categoryReviewLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerPadding.snp.bottom).offset(32)
        }
        
        donutChartView.snp.makeConstraints { make in
            make.top.equalTo(categoryReviewLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(250)
        }

        categoryListView.snp.makeConstraints { make in
            make.top.equalTo(donutChartView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }

    override func configureView() {
        super.configureView()
    }
}
