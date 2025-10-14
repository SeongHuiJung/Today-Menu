//
//  CategoryCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/12/25.
//

import UIKit
import SnapKit

final class CategoryCell: BaseTableViewCell {
    
    private let paddingView = {
        let view = UIView()
        view.backgroundColor = .mainPoint
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    private let nameLabel = BasicLabel(text: "", alignment: .left, size: 16, weight: .semibold, textColor: .fontWhite)
    
    private let percentageLabel = BasicLabel(text: "", alignment: .right, size: 14, weight: .medium, textColor: .fontWhite)

    private let countLabel = BasicLabel(text: "", alignment: .right, size: 14, weight: .medium, textColor: .fontWhite)

    override func configureHierarchy() {
        contentView.addSubview(paddingView)
        [nameLabel, percentageLabel, countLabel].forEach { paddingView.addSubview($0) }
    }

    override func configureLayout() {
        paddingView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.top.equalToSuperview().inset(10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        countLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        percentageLabel.snp.makeConstraints { make in
            make.right.equalTo(countLabel.snp.left).offset(-20)
            make.centerY.equalToSuperview()
        }
    }

    override func configureView() {
        backgroundColor = .clear
        selectionStyle = .none
    }

    func configure(with data: CategoryCellDataModel, index: Int) {
        nameLabel.text = data.name
        percentageLabel.text = String(format: "%.0f%%", data.percentage * 100)
        countLabel.text = "\(data.count)회"

        let backgroundColors: [UIColor] = [.point0, .point1, .point2, .point3, .point4]
        paddingView.backgroundColor = index < 5 ? backgroundColors[index] : .point4

        let fontColor: UIColor
        switch index {
        case 0, 1:
            fontColor = .fontWhite
        case 2:
            fontColor = .fontPoint2
        case 3:
            fontColor = .fontPoint3
        default:
            fontColor = .fontPoint4
        }

        nameLabel.textColor = fontColor
        percentageLabel.textColor = fontColor
        countLabel.textColor = fontColor
    }
}
