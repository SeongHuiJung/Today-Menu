//
//  CategoryCollectionViewCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/7/25.
//

import UIKit
import SnapKit

final class CategoryCollectionViewCell: BaseCollectionViewCell {

    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()

    private let titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.context, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()

    override func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
