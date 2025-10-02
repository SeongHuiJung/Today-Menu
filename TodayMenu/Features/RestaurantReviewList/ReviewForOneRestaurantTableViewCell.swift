//
//  ReviewForOneRestaurantTableViewCell.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import UIKit
import SnapKit

final class ReviewForOneRestaurantTableViewCell: BaseTableViewCell {
    
    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.08
        return view
    }()
    
    private let foodImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let contentStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let foodNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.subTitle, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.small, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let ratingContainerView = UIView()
    
    private let starStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .center
        return stackView
    }()
    
    private let ratingLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.regular, weight: .semibold)
        label.textColor = .systemOrange
        return label
    }()
    
    private let commentLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.regular)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    private let companionContainerView = UIView()
    
    private let companionIconView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let companionLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.small)
        label.textColor = .systemGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupStarViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(foodImageView)
        
        [foodNameLabel, dateLabel, ratingContainerView, commentLabel, companionContainerView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        [starStackView, ratingLabel].forEach {
            ratingContainerView.addSubview($0)
        }
        
        [companionIconView, companionLabel].forEach {
            companionContainerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        foodImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(100)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(foodImageView.snp.leading).offset(-12)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        starStackView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        ratingLabel.snp.makeConstraints {
            $0.centerY.equalTo(starStackView)
            $0.leading.equalTo(starStackView.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        ratingContainerView.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        companionIconView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        
        companionLabel.snp.makeConstraints {
            $0.leading.equalTo(companionIconView.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        companionContainerView.snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
    
    private func setupStarViews() {
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .systemOrange
            starImageView.snp.makeConstraints {
                $0.size.equalTo(16)
            }
            starStackView.addArrangedSubview(starImageView)
        }
    }
    
    func configure(with review: Review) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy. M. d."
        dateLabel.text = formatter.string(from: review.ateAt)
        
        ratingLabel.text = String(format: "%.1f", review.rating)
        
        updateStars(rating: review.rating)
        
        if let firstFood = review.food.first {
            foodNameLabel.text = firstFood.name
        } else {
            foodNameLabel.text = "메뉴 정보 없음"
        }
        
        if let comment = review.comment, !comment.isEmpty {
            commentLabel.text = comment
            commentLabel.isHidden = false
        } else {
            commentLabel.text = ""
            commentLabel.isHidden = true
        }
        
        if let firstCompanion = review.companion.first,
           let companionType = CompanionType(rawValue: firstCompanion.type) {
            let companionText = companionType.displayName
            companionLabel.text = companionText
            companionContainerView.isHidden = false
        } else {
            companionContainerView.isHidden = true
        }
        
        // 이미지 처리
        if !review.photos.isEmpty, let firstPhotoPath = review.photos.first {
            // TODO: 실제 이미지 로드 로직 구현
            foodImageView.isHidden = false
            foodImageView.backgroundColor = .systemGray5
            
            // 임시로 placeholder 이미지 설정
            foodImageView.image = UIImage(systemName: "photo")
            foodImageView.tintColor = .systemGray3
            
            contentStackView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalTo(foodImageView.snp.leading).offset(-12)
                $0.bottom.equalToSuperview().offset(-16)
            }
        } else {
            foodImageView.isHidden = true
            
            contentStackView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview().offset(-16)
                $0.bottom.equalToSuperview().offset(-16)
            }
        }
    }
    
    private func updateStars(rating: Double) {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        for (index, view) in starStackView.arrangedSubviews.enumerated() {
            guard let starImageView = view as? UIImageView else { continue }
            
            if index < fullStars {
                starImageView.image = UIImage(systemName: "star.fill")
            } else if index == fullStars && hasHalfStar {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
            } else {
                starImageView.image = UIImage(systemName: "star")
            }
        }
    }
}
