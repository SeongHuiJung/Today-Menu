//
//  MakeFoodReviewView.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit
import SnapKit

final class MakeFoodReviewView: BaseView {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let requiredInfoLabel = BasicLabel(text: "필수 정보", alignment: .left, size: FontSize.subTitle, weight: .semibold)
    // 메뉴 이름
    let foodNameLabel = BasicLabel(text: "메뉴 이름", alignment: .left, size: FontSize.regular, weight: .medium)
    let foodNameTextField = BasicTextField.reviewStyle(placeholder: "예: 매운돈까스, 라멘, 피자...")
    
    // 별점
    let ratingLabel = BasicLabel(text: "별점", alignment: .left, size: FontSize.subTitle, weight: .semibold)
    let starStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    var starButtons: [UIButton] = []
    let ratingPromptLabel = BasicLabel(text: "별점을 선택해주세요", alignment: .center, size: FontSize.regular, weight: .medium, textColor: .point)
    
    // 먹은 시간
    let eatTimeLabel = BasicLabel(text: "먹은 시간", alignment: .left, size: FontSize.subTitle, weight: .semibold)
    let datePickerContainer = UIView()
    let datePickerButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: FontSize.regular)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    let datePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        picker.isHidden = true
        return picker
    }()
    
    // 선택 정보
    let optionalInfoLabel = BasicLabel(text: "선택 정보", alignment: .left, size: FontSize.subTitle, weight: .semibold)
    let storeNameLabel = BasicLabel(text: "식당 정보", alignment: .left, size: FontSize.regular, weight: .medium)
    
    // 식당 검색 버튼
    let restaurantSearchButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "customLightGray")
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: FontSize.regular)
        button.setTitle("🔍 식당 검색", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    // 선택된 식당 정보 뷰
    let selectedRestaurantView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "point")?.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(named: "point")?.cgColor
        view.isHidden = true
        return view
    }()
    
    let selectedRestaurantNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.subTitle, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let selectedRestaurantAddressLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let removeRestaurantButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "point")
        return button
    }()
    
    let commentLabel = BasicLabel(text: "코멘트", alignment: .left, size: FontSize.regular, weight: .medium)
    let commentTextView = CustomTextView.reviewStyle(placeholder: "식사는 어떠셨나요? 한줄 평가를 입력해주세요.")
    let taggedPeopleLabel = BasicLabel(text: "함께 먹은 사람", alignment: .left, size: FontSize.regular, weight: .medium)
    let tagStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()
    var tagButtons: [UIButton] = []
    
    // 동적으로 나타나는 텍스트필드
    let companionTextField = {
        let textField = BasicTextField.reviewStyle(placeholder: "함께 먹은 사람을 입력해주세요.")
        textField.isHidden = true // 초기에는 숨김
        textField.alpha = 0 // 애니메이션을 위한 alpha 설정
        return textField
    }()
    
    // 애니메이션을 위한 constraint 저장
    private var companionTextFieldHeightConstraint: Constraint?
    
    // 사진 첨부
    let photoSectionLabel = BasicLabel(text: "사진 첨부", alignment: .left, size: FontSize.subTitle, weight: .semibold)
    let photoUploadView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    let cameraImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let photoPromptLabel = BasicLabel(text: "사진을 업로드하세요", alignment: .center, size: FontSize.regular, weight: .semibold, textColor: .darkGray)
    let photoSubLabel = BasicLabel(text: "클릭하거나 드래그해서 추가", alignment: .center, size: FontSize.small, textColor: .lightGray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStarButtons()
        setupTagButtons()
        setupDatePicker()
    }
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [requiredInfoLabel, foodNameLabel, foodNameTextField, ratingLabel, starStackView, ratingPromptLabel,
         eatTimeLabel, datePickerContainer, datePicker, optionalInfoLabel, storeNameLabel, restaurantSearchButton,
         selectedRestaurantView, commentLabel, commentTextView, taggedPeopleLabel,
         tagStackView, companionTextField, photoSectionLabel, photoUploadView].forEach {
            contentView.addSubview($0)
        }
        
        [datePickerButton].forEach { datePickerContainer.addSubview($0) }
        [cameraImageView, photoPromptLabel, photoSubLabel].forEach { photoUploadView.addSubview($0) }
        [selectedRestaurantNameLabel, selectedRestaurantAddressLabel, removeRestaurantButton].forEach {
            selectedRestaurantView.addSubview($0)
        }
    }
    override func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        requiredInfoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        foodNameLabel.snp.makeConstraints {
            $0.top.equalTo(requiredInfoLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        foodNameTextField.snp.makeConstraints {
            $0.top.equalTo(foodNameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        ratingLabel.snp.makeConstraints {
            $0.top.equalTo(foodNameTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(ratingLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(250)
        }
        
        ratingPromptLabel.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        eatTimeLabel.snp.makeConstraints {
            $0.top.equalTo(ratingPromptLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        datePickerContainer.snp.makeConstraints {
            $0.top.equalTo(eatTimeLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        datePickerButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(datePickerContainer.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        optionalInfoLabel.snp.makeConstraints {
            $0.top.equalTo(datePickerContainer.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        storeNameLabel.snp.makeConstraints {
            $0.top.equalTo(optionalInfoLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        restaurantSearchButton.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        
        selectedRestaurantView.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(80)
        }
        
        selectedRestaurantNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(removeRestaurantButton.snp.leading).offset(-12)
        }
        
        selectedRestaurantAddressLabel.snp.makeConstraints {
            $0.top.equalTo(selectedRestaurantNameLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(removeRestaurantButton.snp.leading).offset(-12)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        removeRestaurantButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(selectedRestaurantView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        commentTextView.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(100)
        }
        
        taggedPeopleLabel.snp.makeConstraints {
            $0.top.equalTo(commentTextView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tagStackView.snp.makeConstraints {
            $0.top.equalTo(taggedPeopleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        
        companionTextField.snp.makeConstraints {
            $0.top.equalTo(tagStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            companionTextFieldHeightConstraint = $0.height.equalTo(0).constraint // 초기에는 높이 0
        }
        
        photoSectionLabel.snp.makeConstraints {
            $0.top.equalTo(companionTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        photoUploadView.snp.makeConstraints {
            $0.top.equalTo(photoSectionLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(120)
            $0.bottom.equalToSuperview().offset(-40)
        }
        
        cameraImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-15)
            $0.width.height.equalTo(40)
        }
        
        photoPromptLabel.snp.makeConstraints {
            $0.top.equalTo(cameraImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        photoSubLabel.snp.makeConstraints {
            $0.top.equalTo(photoPromptLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }
}
    
extension MakeFoodReviewView {
    private func setupDatePicker() {
        datePicker.alpha = 0
    }
    
    func toggleDatePicker() {
        datePicker.isHidden.toggle()
        
        // datePicker on/off에 따라 optionalInfoLabel 위치 조정
        if datePicker.isHidden {
            optionalInfoLabel.snp.remakeConstraints {
                $0.top.equalTo(datePickerContainer.snp.bottom).offset(32)
                $0.leading.equalToSuperview().offset(20)
            }
        } else {
            optionalInfoLabel.snp.remakeConstraints {
                $0.top.equalTo(datePicker.snp.bottom).offset(32)
                $0.leading.equalToSuperview().offset(20)
            }
        }

        UIView.animate(withDuration: 0.3) {
            self.datePicker.alpha = self.datePicker.isHidden ? 0 : 1
            self.layoutIfNeeded()
        }
    }
    
    func updateDateDisplay(_ dateString: String) {
        datePickerButton.setTitle(dateString, for: .normal)
    }
    
    func setDatePickerDate(_ date: Date) {
        datePicker.date = date
    }

    private func setupStarButtons() {
        for i in 0..<5 {
            let button = StarButton(tag: i + 1)
            starButtons.append(button)
            starStackView.addArrangedSubview(button)
        }
    }
    
    private func setupTagButtons() {
        let tags = ["혼자", "친구", "가족", "연인", "동료"]
        for tag in tags {
            let button = TagButton(title: tag)
            tagButtons.append(button)
            tagStackView.addArrangedSubview(button)
        }
    }
    
    func updateStarRating(_ rating: Int) {
        for (index, button) in starButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    func updateStarRatingDisplay(_ text: String, isHighlighted: Bool) {
        ratingPromptLabel.text = text
        ratingPromptLabel.textColor = isHighlighted ? UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) : .point
    }
    
    func selectTag(at index: Int) {
        // 모든 버튼 비활성화
        for button in tagButtons {
            button.isSelected = false
        }
        
        // 선택된 버튼 활성화
        if index >= 0 && index < tagButtons.count {
            tagButtons[index].isSelected = true
        }
    }
    
    func showCompanionTextField() {
        companionTextField.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.companionTextFieldHeightConstraint?.update(offset: 44)
            self.companionTextField.alpha = 1.0
            self.layoutIfNeeded()
        }
    }
    
    func hideCompanionTextField() {
        UIView.animate(withDuration: 0.3, animations: {
            self.companionTextFieldHeightConstraint?.update(offset: 0)
            self.companionTextField.alpha = 0.0
            self.layoutIfNeeded()
        }) { _ in
            self.companionTextField.isHidden = true
        }
    }
    
    func clearCompanionTextField() {
        companionTextField.text = ""
    }
    
    func populateInitialData(foodName: String, storeName: String) {
        foodNameTextField.text = foodName
    }
    
    func showSelectedRestaurant(_ restaurant: RestaurantData) {
        selectedRestaurantNameLabel.text = restaurant.restaurantName
        selectedRestaurantAddressLabel.text = restaurant.addressName
        
        // 버튼 숨기고 선택된 뷰 표시
        restaurantSearchButton.isHidden = true
        selectedRestaurantView.isHidden = false
    }
    
    func hideSelectedRestaurant() {
        selectedRestaurantView.isHidden = true
        restaurantSearchButton.isHidden = false
        
        selectedRestaurantNameLabel.text = ""
        selectedRestaurantAddressLabel.text = ""
    }
}
