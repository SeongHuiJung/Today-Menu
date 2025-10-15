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

    let headerLabel = BasicLabel(text: "모모찌가 분석한 음식 리포트에요!", alignment: .left, size: 20, weight: .bold, textColor: .fontPoint0)

    let characterImage = UIImageView(image: UIImage(named: "logoCharacter"))
    
    private let emptyPadding = UIImageView(image: UIImage(named: "emptyPadding"))
    private let warningIcon = UIImageView(image: UIImage(named: "warning"))
    private let emptyInfoLabel = BasicLabel(text: "앗, 아직 음식리뷰가 없네요", alignment: .center, size: 16, weight: .semibold, textColor: .fontPoint1)
    private let emptyDescriptionLabel = BasicLabel(text: "리뷰를 작성하면 통계를 확인할 수 있어요.", alignment: .center, size: 14, textColor: .fontPoint5)
    
    private let categoryReviewLabel = PaddingLabel(insets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18), text: "카테고리별 리뷰", alignment: .center, size: 14, backgroundColor: .pointBackground1, textColor: .fontPoint0 , weight: .semibold, cornerRadius: 20)
    
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
        [scrollView, emptyPadding].forEach { self.addSubview($0) }
        scrollView.addSubview(contentView)
        [headerPadding, characterImage, categoryReviewLabel, donutChartView, categoryListView].forEach { contentView.addSubview($0) }
        headerPadding.addSubview(headerLabel)
        [warningIcon, emptyInfoLabel, emptyDescriptionLabel].forEach { emptyPadding.addSubview($0) }
    }

    override func configureLayout() {

        emptyPadding.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }

        warningIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(28)
            make.width.equalTo(35)
            make.height.equalTo(33)
        }
        
        emptyInfoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(warningIcon.snp.bottom).offset(20)
        }
        
        emptyDescriptionLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(36)
        }
        
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
            make.right.equalTo(characterImage.snp.left).offset(-16)
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
            make.top.equalTo(categoryReviewLabel.snp.bottom).offset(44)
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

    func updateUIForDataState(hasData: Bool) {
        if hasData {
            scrollView.isHidden = false
            headerPadding.isHidden = false
            characterImage.isHidden = false
            categoryReviewLabel.isHidden = false
            donutChartView.isHidden = false
            categoryListView.isHidden = false
            emptyPadding.isHidden = true
        } else {
            scrollView.isHidden = true
            emptyPadding.isHidden = false
        }
    }
}
