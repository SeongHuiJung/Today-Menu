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
    
    private let foodNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.insertSubview(backgroundColorView, at: 0)
        [dateLabel, foodImageView, foodNameLabel].forEach {
            contentView.addSubview($0)
        }
        
        backgroundColorView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.horizontalEdges.equalToSuperview().inset(4)
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
        foodNameLabel.text = nil
        dateLabel.text = nil
    }
    
    func configure(date: Int, foodName: String, photoPath: String?) {
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
        
        backgroundColorView.isHidden = false
        foodImageView.isHidden = false
        foodNameLabel.isHidden = false
    }
}
