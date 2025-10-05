//
//  CalendarReviewCell.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
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
        view.backgroundColor = UIColor.point
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
        label.textColor = UIColor.point
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let backgroundColorView = {
        let view = UIView()
        view.backgroundColor = UIColor.pointBackground
        view.layer.borderColor = UIColor.borderPoint.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        
        view.layer.shadowColor = UIColor.red.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
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
        [backgroundColorView, dateLabel, foodImageView, foodNameLabel, badgeView].forEach {
            contentView.addSubview($0)
        }
        badgeView.addSubview(badgeLabel)
        
        backgroundColorView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
        
        badgeView.snp.makeConstraints {
            $0.top.equalTo(foodImageView.snp.top).offset(-4)
            $0.trailing.equalTo(foodImageView.snp.trailing).offset(4)
            badgeWidthConstraint = $0.width.greaterThanOrEqualTo(18).constraint
            $0.height.equalTo(14)
        }
        
        badgeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
        }
        
        foodImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(foodImageView.snp.width)
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
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
        foodImageView.layer.cornerRadius = 16
        foodNameLabel.text = nil
        dateLabel.text = nil
        badgeView.isHidden = true
        badgeLabel.text = nil
    }
    
    func configure(date: Int, foodName: String, photoPath: String?, additionalReviewCount: Int) {
        dateLabel.text = "\(date)"
        foodNameLabel.text = foodName
        
        // 사진이 있으면 CalendarPicture 폴더에서 로드
        if let photoFileName = photoPath, !photoFileName.isEmpty {
            if let image = ImageStorageManager.shared.loadImage(fileName: photoFileName, type: .calendar) {
                foodImageView.image = image
                foodImageView.contentMode = .scaleAspectFill
                foodImageView.layer.cornerRadius = 5
                foodImageView.snp.remakeConstraints {
                    $0.horizontalEdges.equalToSuperview().inset(8)
                    $0.height.equalTo(foodImageView.snp.width)
                    $0.top.equalTo(dateLabel.snp.bottom)
                }
            } else {
                // 이미지 로드 실패 시 기본 아이콘
                foodImageView.image = UIImage(systemName: "fork.knife.circle.fill")
                foodImageView.tintColor = UIColor.lightPoint
                foodImageView.contentMode = .scaleAspectFit
            }
        } else {
            // 사진이 없으면 기본 아이콘
            foodImageView.image = UIImage(systemName: "fork.knife.circle.fill")
            foodImageView.tintColor = UIColor.lightPoint
            foodImageView.contentMode = .scaleAspectFit
        }
        
        // 뱃지 처리
        if additionalReviewCount > 0 {
            let displayCount = additionalReviewCount > 99 ? "99+" : "+\(additionalReviewCount)"
            badgeLabel.text = displayCount
            badgeView.isHidden = false
            
            // 글자 수에 따라 너비 조정
            if additionalReviewCount > 99 {
                badgeWidthConstraint?.update(offset: 26)
            } else if additionalReviewCount >= 10 {
                badgeWidthConstraint?.update(offset: 22)
            } else {
                badgeWidthConstraint?.update(offset: 18)
            }
        } else {
            badgeView.isHidden = true
        }
        
        // cornerRadius 적용
        badgeView.layoutIfNeeded()
        badgeView.layer.cornerRadius = badgeView.frame.height / 2
        
        backgroundColorView.isHidden = false
        foodImageView.isHidden = false
        foodNameLabel.isHidden = false
    }
}
