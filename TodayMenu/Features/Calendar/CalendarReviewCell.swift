//
//  CalendarReviewCell.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import UIKit
import FSCalendar
import SnapKit

final class CalendarReviewCell: FSCalendarCell {
    
    private let foodImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let badgeView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.26, blue: 0.21, alpha: 1.0)
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let foodNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(named: "point")
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let backgroundColorView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "point")?.withAlphaComponent(0.15)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private var badgeWidthConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.insertSubview(backgroundColorView, at: 0)
        [dateLabel, badgeView, foodImageView, foodNameLabel].forEach {
            contentView.addSubview($0)
        }
        badgeView.addSubview(badgeLabel)
        
        backgroundColorView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.trailing.equalToSuperview().inset(4)
        }
        
        badgeView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(dateLabel.snp.bottom).offset(2)
            badgeWidthConstraint = $0.width.greaterThanOrEqualTo(14).constraint
            $0.height.equalTo(14)
        }
        
        badgeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
        }
        
        foodImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(badgeView.snp.bottom).offset(2)
            $0.width.height.equalTo(32)
        }
        
        foodNameLabel.snp.makeConstraints {
            $0.top.equalTo(foodImageView.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(2)
            $0.bottom.lessThanOrEqualToSuperview().offset(-4)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodImageView.image = nil
        foodNameLabel.text = nil
        dateLabel.text = nil
        badgeView.isHidden = true
        badgeLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        badgeView.layer.cornerRadius = badgeView.frame.height / 2
    }
    
    func configure(date: Int, foodName: String, photoPath: String?, additionalReviewCount: Int) {
        dateLabel.text = "\(date)"
        foodNameLabel.text = foodName
        
        if let photoPath = photoPath, !photoPath.isEmpty {
            // TODO: 실제 이미지 로드 구현
            foodImageView.image = UIImage(systemName: "fork.knife.circle.fill")
            foodImageView.tintColor = UIColor(named: "point")
        } else {
            foodImageView.image = UIImage(systemName: "fork.knife.circle.fill")
            foodImageView.tintColor = UIColor(named: "point")
        }
        
        if additionalReviewCount > 0 {
            let displayCount = additionalReviewCount > 99 ? "99+" : "+\(additionalReviewCount)"
            badgeLabel.text = displayCount
            badgeView.isHidden = false
            
            if additionalReviewCount > 99 {
                badgeWidthConstraint?.update(offset: 22)
            } else if additionalReviewCount >= 10 {
                badgeWidthConstraint?.update(offset: 18)
            } else {
                badgeWidthConstraint?.update(offset: 14)
            }
            
            foodImageView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(badgeView.snp.bottom).offset(2)
                $0.width.height.equalTo(32)
            }
        } else {
            badgeView.isHidden = true
            
            foodImageView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(dateLabel.snp.bottom).offset(4)
                $0.width.height.equalTo(32)
            }
        }
        
        backgroundColorView.isHidden = false
        foodImageView.isHidden = false
        foodNameLabel.isHidden = false
    }
}
