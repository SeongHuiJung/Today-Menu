//
//  FoodRecommendView.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit
import SnapKit

final class FoodRecommendView: BaseView {

    let cardContainer = BasicView(backgroundColor: .red, cornerRadius: 10)
    private let emojiLabel = BasicLabel(text: "", alignment: .center, size: 68)
    private let titleLabel = BasicLabel(text: "", alignment: .left, size: 24, weight: .bold, textColor: .white
    )
    private let subtitleLabel = BasicLabel(text: "", alignment: .left, size: 14, textColor: UIColor.white.withAlphaComponent(0.85))
    private let chipLabel = {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
        label.textColor = UIColor(red: 0.94, green: 0.12, blue: 0.12, alpha: 1.0)
        label.backgroundColor = .white
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()
    let passButton = BarButton(title: "다시뽑기", size: FontSize.subTitle, textColor: .fontLightGray, backgroundColor: .customLightGray)
    let acceptButton = BarButton(title: "메뉴선택", size: FontSize.subTitle, textColor: .fontWhite, backgroundColor: .point)
    let reviewButton = {
        let button = BarButton(title: "리뷰작성", size: FontSize.subTitle, textColor: .fontWhite, backgroundColor: .point)
        button.isHidden = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func render(_ item: FoodRecommendation) {
        emojiLabel.text = item.emoji
        titleLabel.text = item.title
        subtitleLabel.text = "\(item.place) · \(String(format: "%.1f", item.distanceKm))km"
        chipLabel.text = item.category
    }
    
    func showAcceptedUI(_ isAccepted: Bool) {
        passButton.isHidden   = isAccepted
        acceptButton.isHidden = isAccepted
        reviewButton.isHidden = !isAccepted
    }
    
    // MARK: - BaseView
    override func configureHierarchy() {
        addSubview(cardContainer)
        [cardContainer, passButton, acceptButton, reviewButton].forEach { self.addSubview($0) }
        [emojiLabel, titleLabel, subtitleLabel, chipLabel].forEach { cardContainer.addSubview($0) }
    }
    
    override func configureLayout() {
        cardContainer.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(420)
        }
        emojiLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
        }
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-6)
        }
        subtitleLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.bottom.equalTo(chipLabel.snp.top).offset(-10)
        }
        chipLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        passButton.snp.makeConstraints {
            $0.top.equalTo(cardContainer.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(24)
            $0.height.equalTo(56)
            $0.right.equalTo(self.snp.centerX).offset(-12)
        }
        acceptButton.snp.makeConstraints {
            $0.top.equalTo(passButton)
            $0.right.equalToSuperview().inset(24)
            $0.height.equalTo(56)
            $0.left.equalTo(self.snp.centerX).offset(12)
        }
        reviewButton.snp.makeConstraints {
            $0.top.equalTo(cardContainer.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }
}
