//
//  CategoryHeaderView.swift
//  TodayMenu
//
//  Created by 정성희 on 10/7/25.
//

import UIKit
import SnapKit

final class CategoryHeaderView: UICollectionReusableView {

    static let identifier = "CategoryHeaderView"

    private let titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.bold, weight: .bold)
        label.textColor = .fontBlack
        return label
    }()

    private let iconImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureHierarchy() {
        [iconImageView, titleLabel].forEach {
            addSubview($0)
        }
    }

    private func configureLayout() {
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
    }

    private func configureView() {
        backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
    }

    func configure(title: String, icon: UIImage?) {
        titleLabel.text = title
        iconImageView.image = icon
    }
}
