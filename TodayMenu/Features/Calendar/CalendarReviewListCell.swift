//
//  CalendarReviewListCell.swift
//  TodayMenu
//
//  Created by Claude on 10/2/25.
//

import UIKit
import SnapKit

final class CalendarReviewListCell: UITableViewCell {
    
    private let timeLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    
    private let foodImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let foodNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let categoryLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodImageView.image = nil
        foodNameLabel.text = nil
        categoryLabel.text = nil
        timeLabel.text = nil
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        [timeLabel, foodImageView, foodNameLabel, categoryLabel].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
        }
        
        foodImageView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(60)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        foodNameLabel.snp.makeConstraints {
            $0.top.equalTo(foodImageView)
            $0.leading.equalTo(foodImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(foodNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(foodNameLabel)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    func configure(review: Review) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        timeLabel.text = dateFormatter.string(from: review.ateAt)
        
        foodNameLabel.text = review.food.first?.name ?? "음식"
        categoryLabel.text = review.food.first?.category ?? ""
        
        if let photoPath = review.photos.first {
            // TODO: 사진 로드
        } else {
            foodImageView.image = UIImage(systemName: "photo")
            foodImageView.tintColor = .systemGray3
        }
    }
}
