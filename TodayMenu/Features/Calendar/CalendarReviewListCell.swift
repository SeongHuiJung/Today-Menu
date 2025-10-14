//
//  CalendarReviewListCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/2/25.
//

import UIKit
import SnapKit

final class CalendarReviewListCell: BaseTableViewCell {
    
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
    
    private let starStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let commentLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    private let companionLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray2
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
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        contentView.addSubview(containerView)
        [timeLabel, foodImageView, foodNameLabel, categoryLabel, starStackView, commentLabel, companionLabel].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        super.configureLayout()
        
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
            $0.width.height.equalTo(80)
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
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(4)
            $0.leading.equalTo(foodNameLabel)
            $0.height.equalTo(16)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(foodImageView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        companionLabel.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodImageView.image = nil
        foodNameLabel.text = nil
        categoryLabel.text = nil
        timeLabel.text = nil
        commentLabel.text = nil
        companionLabel.text = nil
        starStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setupStarRating(_ rating: Int) {
        starStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = i < rating ? .mainPoint : .systemGray4
            starImageView.image = UIImage(systemName: i < rating ? "star.fill" : "star")
            starStackView.addArrangedSubview(starImageView)
            
            starImageView.snp.makeConstraints {
                $0.width.height.equalTo(16)
            }
        }
    }
    
    private func formatCompanionText(_ companions: [Companion]) -> String {
        let names = companions.compactMap { $0.name }.filter { !$0.isEmpty }
        guard let companionType = CompanionType(rawValue: companions.first?.type ?? "alone") else { return "" }
        if companionType == .alone {
            return companionType.displayName
        }
        else {
            if names.isEmpty {
                return "👥 \(companionType.displayName)"
            } else {
                let nameList = names.joined(separator: ", ")
                return "👥 \(companionType.displayName) \(nameList)"
            }
        }
    }
    
    func configure(review: Review) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        timeLabel.text = dateFormatter.string(from: review.ateAt)
        
        foodNameLabel.text = review.food.first?.name ?? "음식"
        
        // FoodReview의 foodId로 FoodType 찾기
        if let foodReview = review.food.first {
            let foodRepository = FoodRepository()
            if let foodType = foodRepository.getFoodType(by: foodReview.foodId) {
                categoryLabel.text = foodType.category
            } else {
                categoryLabel.text = ""
            }
        } else {
            categoryLabel.text = ""
        }
        
        setupStarRating(Int(review.rating))
        
        if let comment = review.comment, !comment.isEmpty {
            commentLabel.text = comment
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }
        
        if !review.companion.isEmpty {
            companionLabel.text = formatCompanionText(Array(review.companion))
            companionLabel.isHidden = false
        } else {
            companionLabel.isHidden = true
        }
        
        // 사진이 있으면 ReviewPicture 폴더에서 로드
        if let photoFileName = review.photos.first, !photoFileName.isEmpty {
            if let image = ImageStorageManager.shared.loadImage(fileName: photoFileName, type: .review) {
                foodImageView.image = image
                foodImageView.contentMode = .scaleAspectFill
            } else {
                // 이미지 로드 실패 시 기본 아이콘
                foodImageView.image = UIImage(systemName: "photo")
                foodImageView.tintColor = .systemGray3
                foodImageView.contentMode = .scaleAspectFit
            }
        } else {
            // 사진이 없으면 기본 아이콘
            foodImageView.image = UIImage(systemName: "photo")
            foodImageView.tintColor = .systemGray3
            foodImageView.contentMode = .scaleAspectFit
        }
    }
}
