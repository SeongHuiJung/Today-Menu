//
//  CategoryCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/12/25.
//

import UIKit
import SnapKit

final class CategoryCell: BaseTableViewCell {

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    override func configureHierarchy() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(percentageLabel)
        contentView.addSubview(countLabel)
    }

    override func configureLayout() {
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        countLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }

        percentageLabel.snp.makeConstraints { make in
            make.trailing.equalTo(countLabel.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    override func configureView() {
        backgroundColor = .clear
        selectionStyle = .none
    }

    func configure(with data: CategoryCellDataModel) {
        nameLabel.text = data.name
        percentageLabel.text = String(format: "%.0f%%", data.percentage * 100)
        countLabel.text = "\(data.count)회"
    }
}
