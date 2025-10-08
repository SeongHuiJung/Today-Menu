//
//  CuisineTableViewCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/7/25.
//

import UIKit
import SnapKit

final class CuisineTableViewCell: BaseTableViewCell {

    private let titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.context, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()

    private let selectionIndicator = {
        let view = UIView()
        view.backgroundColor = UIColor.point2
        view.isHidden = true
        return view
    }()

    override func configureHierarchy() {
        [titleLabel, selectionIndicator].forEach {
            contentView.addSubview($0)
        }
    }

    override func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        selectionIndicator.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(4)
            $0.height.equalTo(24)
        }
    }

    override func configureView() {
        backgroundColor = .white
        selectionStyle = .none
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        titleLabel.textColor = isSelected ? UIColor.point2 : .darkGray
        titleLabel.font = isSelected ? .systemFont(ofSize: FontSize.context, weight: .bold) : .systemFont(ofSize: FontSize.context, weight: .medium)
        selectionIndicator.isHidden = !isSelected
        backgroundColor = isSelected ? UIColor.point2.withAlphaComponent(0.15) : .white
    }
}
