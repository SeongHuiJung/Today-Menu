//
//  RestaurantSearchCell.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import UIKit
import SnapKit

final class RestaurantSearchCell: BaseTableViewCell {
    
    private let restaurantNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.subTitle, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let addressLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.regular)
        label.textColor = .darkGray
        return label
    }()
    
    private let categoryLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.small)
        label.textColor = .lightGray
        return label
    }()
    
    override func configureHierarchy() {
        [restaurantNameLabel, addressLabel, categoryLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        restaurantNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(restaurantNameLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(restaurantNameLabel)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(restaurantNameLabel)
            $0.bottom.equalToSuperview().offset(-16) // bottom constraint 추가
        }
    }
    
    override func configureView() {
        selectionStyle = .default
        backgroundColor = .white
    }
    
    func configure(with restaurant: RestaurantData) {
        restaurantNameLabel.text = restaurant.restaurantName
        addressLabel.text = restaurant.addressName
        
        // 카테고리 정보 포맷팅
        let category = restaurant.categoryName.components(separatedBy: " > ").last ?? restaurant.categoryName
        let distance = Int(restaurant.distance) ?? 0
        
        if distance > 0 {
            categoryLabel.text = "\(category) · \(formatDistance(distance))"
        } else {
            categoryLabel.text = category
        }
    }
    
    private func formatDistance(_ distance: Int) -> String {
        if distance < 1000 {
            return "\(distance)m"
        } else {
            let km = Double(distance) / 1000.0
            return String(format: "%.1fkm", km)
        }
    }
}
