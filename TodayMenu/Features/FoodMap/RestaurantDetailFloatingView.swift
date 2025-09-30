//
//  RestaurantDetailFloatingView.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import UIKit
import SnapKit

final class RestaurantDetailFloatingView: BaseView {
    
    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let closeButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let restaurantNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let cuisineLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let starStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .center
        return stackView
    }()
    
    private let ratingLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemOrange
        return label
    }()
    
    private let reviewDateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let reviewButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 255/255, green: 147/255, blue: 120/255, alpha: 1.0)
        button.setTitle("내가 남긴 리뷰보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    var onClose: (() -> Void)?
    var onReviewButtonTap: (() -> Void)?
    
    override func configureHierarchy() {
        backgroundColor = .clear
        addSubview(containerView)
        
        [closeButton, restaurantNameLabel, cuisineLabel,
         starStackView, ratingLabel, reviewDateLabel, reviewButton].forEach {
            containerView.addSubview($0)
        }
        
        setupStarViews()
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(28)
        }
        
        restaurantNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(closeButton.snp.leading).offset(-8)
        }
        
        cuisineLabel.snp.makeConstraints {
            $0.top.equalTo(restaurantNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(restaurantNameLabel)
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(cuisineLabel.snp.bottom).offset(12)
            $0.leading.equalTo(restaurantNameLabel)
            $0.height.equalTo(20)
        }
        
        ratingLabel.snp.makeConstraints {
            $0.centerY.equalTo(starStackView)
            $0.leading.equalTo(starStackView.snp.trailing).offset(8)
        }
        
        reviewDateLabel.snp.makeConstraints {
            $0.centerY.equalTo(starStackView)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        reviewButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    override func configureView() {
        backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)
        reviewButton.addTarget(self, action: #selector(handleReviewButton), for: .touchUpInside)
    }
    
    private func setupStarViews() {
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .systemOrange
            starImageView.snp.makeConstraints {
                $0.size.equalTo(20)
            }
            starStackView.addArrangedSubview(starImageView)
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
    
    @objc private func handleCloseButton() {
        onClose?()
    }
    
    @objc private func handleReviewButton() {
        onReviewButtonTap?()
    }
    
    func configure(restaurantName: String, lastVisit: Date, averageRating: Double, cuisine: String) {
        restaurantNameLabel.text = restaurantName
        cuisineLabel.text = cuisine
        ratingLabel.text = String(format: "%.1f점", averageRating)
        reviewDateLabel.text = formatDate(lastVisit)
        
        updateStars(rating: averageRating)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 E요일"
        
        return formatter.string(from: date) + " 방문"
    }
}
