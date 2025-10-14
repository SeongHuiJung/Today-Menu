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
    
    let photoSectionLabel = BasicLabel(text: "음식 사진", alignment: .left, size: FontSize.bold, weight: .bold)
    
    let photoCaptureButton = PhotoCaptureButton()
    
    lazy var selectedPhotosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return cv
    }()
    
    let foodNameLabel = BasicLabel(text: "음식 이름", alignment: .left, size: FontSize.bold, weight: .bold)
    let foodNameTextField = BasicTextField.reviewStyle(placeholder: "먹은 음식")

    // 음식 카테고리 설정 Label (Calendar에서 온 경우만 표시)
    let categorySectionLabel = {
        let label = BasicLabel(text: "음식 카테고리", alignment: .left, size: FontSize.bold, weight: .bold)
        label.isHidden = true
        return label
    }()

    // 음식 분류 설정 버튼 (Calendar에서 온 경우만 표시)
    let categorySettingButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.customGray2.cgColor
        button.setTitle("음식 분류 설정", for: .normal)
        button.setTitleColor(.fontLightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: FontSize.context, weight: .medium)
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.isHidden = true
        return button
    }()

    let ratingLabel = BasicLabel(text: "별점", alignment: .left, size: FontSize.bold, weight: .bold)
    let starStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.alignment = .center
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()
    var starButtons: [UIButton] = []
    
    let eatTimeLabel = BasicLabel(text: "먹은 시간", alignment: .left, size: FontSize.bold, weight: .bold)
    
    let datePickerButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.customGray2.cgColor
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16)
        button.titleLabel?.font = .systemFont(ofSize: FontSize.context)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let calendarIconView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let datePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        picker.isHidden = true
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let today = Date()
        if let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today) {
            picker.maximumDate = endOfToday
        }
        
        return picker
    }()
    
    let storeNameLabel = BasicLabel(text: "식당 정보", alignment: .left, size: FontSize.bold, weight: .bold)
    
    let restaurantSearchButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.customGray2.cgColor
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 16)
        button.titleLabel?.font = .systemFont(ofSize: FontSize.context)
        button.setTitle("식당 검색", for: .normal)
        button.setTitleColor(.systemGray2, for: .normal)
        return button
    }()
    
    let searchIconView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 선택된 식당 정보 뷰
    let selectedRestaurantView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainPoint.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mainPoint.cgColor
        view.isHidden = true
        return view
    }()
    
    let selectedRestaurantNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.regular, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    let selectedRestaurantAddressLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: FontSize.small)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let removeRestaurantButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor.mainPoint
        return button
    }()
    
    let commentLabel = BasicLabel(text: "코멘트", alignment: .left, size: FontSize.bold, weight: .bold)
    let commentTextView = CustomTextView.reviewStyle(placeholder: "식사는 어떠셨나요? 한줄 평가를 입력해주세요.")
    
    let taggedPeopleLabel = BasicLabel(text: "함께 먹은 사람", alignment: .left, size: FontSize.bold, weight: .bold)
    let tagStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    var tagButtons: [UIButton] = []
    
    // 동적으로 나타나는 텍스트필드
    let companionTextField = {
        let textField = BasicTextField.reviewStyle(placeholder: "함께 먹은 사람을 입력해주세요.")
        textField.isHidden = true
        textField.alpha = 0
        return textField
    }()
    
    private var companionTextFieldHeightConstraint: Constraint?
    
    let saveButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainPoint
        button.setTitle("작성 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: FontSize.subTitle, weight: .semibold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStarButtons()
        setupTagButtons()
        setupDatePicker()
    }
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [photoSectionLabel, photoCaptureButton, selectedPhotosCollectionView,
         foodNameLabel, foodNameTextField, categorySectionLabel, categorySettingButton,
         ratingLabel, starStackView,
         eatTimeLabel, datePickerButton, calendarIconView, datePicker,
         storeNameLabel, restaurantSearchButton, searchIconView, selectedRestaurantView,
         commentLabel, commentTextView,
         taggedPeopleLabel, tagStackView, companionTextField].forEach {
            contentView.addSubview($0)
        }
        
        [selectedRestaurantNameLabel, selectedRestaurantAddressLabel, removeRestaurantButton].forEach {
            selectedRestaurantView.addSubview($0)
        }
        
        addSubview(saveButton)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(saveButton.snp.top).offset(-16)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        // 음식 사진
        photoSectionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        photoCaptureButton.snp.makeConstraints {
            $0.top.equalTo(photoSectionLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(80)
        }
        
        selectedPhotosCollectionView.snp.makeConstraints {
            $0.leading.equalTo(photoCaptureButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(photoCaptureButton)
            $0.height.equalTo(80)
        }
        
        // 음식 이름
        foodNameLabel.snp.makeConstraints {
            $0.top.equalTo(photoCaptureButton.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }
        
        foodNameTextField.snp.makeConstraints {
            $0.top.equalTo(foodNameLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }

        // 음식 카테고리 설정 Label (Calendar에서 온 경우만 표시)
        categorySectionLabel.snp.makeConstraints {
            $0.top.equalTo(foodNameTextField.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }

        // 음식 분류 설정 버튼 (Calendar에서 온 경우만 표시)
        categorySettingButton.snp.makeConstraints {
            $0.top.equalTo(categorySectionLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }

        // 별점
        ratingLabel.snp.makeConstraints {
            $0.top.equalTo(foodNameTextField.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }
        
        starStackView.snp.makeConstraints {
            $0.top.equalTo(ratingLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        // 먹은 시간
        eatTimeLabel.snp.makeConstraints {
            $0.top.equalTo(starStackView.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }
        
        datePickerButton.snp.makeConstraints {
            $0.top.equalTo(eatTimeLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        
        calendarIconView.snp.makeConstraints {
            $0.leading.equalTo(datePickerButton).offset(16)
            $0.centerY.equalTo(datePickerButton)
            $0.width.height.equalTo(20)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(datePickerButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        // 식당 정보
        storeNameLabel.snp.makeConstraints {
            $0.top.equalTo(datePickerButton.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }
        
        restaurantSearchButton.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        
        searchIconView.snp.makeConstraints {
            $0.leading.equalTo(restaurantSearchButton).offset(16)
            $0.centerY.equalTo(restaurantSearchButton)
            $0.width.height.equalTo(20)
        }
        
        selectedRestaurantView.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(70)
        }
        
        selectedRestaurantNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(removeRestaurantButton.snp.leading).offset(-12)
        }
        
        selectedRestaurantAddressLabel.snp.makeConstraints {
            $0.top.equalTo(selectedRestaurantNameLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(removeRestaurantButton.snp.leading).offset(-12)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        removeRestaurantButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        
        // 코멘트
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(selectedRestaurantView.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }
        
        commentTextView.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(120)
        }
        
        // 함께 먹은 사람
        taggedPeopleLabel.snp.makeConstraints {
            $0.top.equalTo(commentTextView.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tagStackView.snp.makeConstraints {
            $0.top.equalTo(taggedPeopleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        companionTextField.snp.makeConstraints {
            $0.top.equalTo(tagStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            companionTextFieldHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        // 하단 여백
        companionTextField.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-100)
        }
        
        // 저장 완료 버튼
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(44)
        }
    }
}

// MARK: - Methods
extension MakeFoodReviewView {
    private func setupDatePicker() {
        datePicker.alpha = 0
    }
    
    func toggleDatePicker() {
        datePicker.isHidden.toggle()
        
        if datePicker.isHidden {
            storeNameLabel.snp.remakeConstraints {
                $0.top.equalTo(datePickerButton.snp.bottom).offset(32)
                $0.leading.equalToSuperview().offset(20)
            }
        } else {
            storeNameLabel.snp.remakeConstraints {
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
           
            button.snp.makeConstraints { make in
                make.width.height.equalTo(32)
            }
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
        // 별점 표시 제거됨
    }
    
    func selectTag(at index: Int) {
        for button in tagButtons {
            button.isSelected = false
        }
        
        if index >= 0 && index < tagButtons.count {
            tagButtons[index].isSelected = true
        }
    }
    
    func showCompanionTextField() {
        companionTextField.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.companionTextFieldHeightConstraint?.update(offset: 52)
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
    
    func populateInitialData(foodName: String, placeholder: String, storeName: String) {
        foodNameTextField.text = foodName
        foodNameTextField.placeholder = placeholder
    }

    func showCategorySettingButton() {
        categorySectionLabel.isHidden = false
        categorySettingButton.isHidden = false

        ratingLabel.snp.remakeConstraints {
            $0.top.equalTo(categorySettingButton.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
        }
    }

    func updateCategoryButtonTitle(_ title: String) {
        categorySettingButton.setTitle(title, for: .normal)
        categorySettingButton.setTitleColor(.black, for: .normal)
        categorySettingButton.layer.borderColor = UIColor.mainPoint.cgColor
    }

    func showSelectedRestaurant(_ restaurant: RestaurantData) {
        selectedRestaurantNameLabel.text = restaurant.restaurantName
        selectedRestaurantAddressLabel.text = restaurant.addressName
        
        restaurantSearchButton.isHidden = true
        searchIconView.isHidden = true
        selectedRestaurantView.isHidden = false
    }
    
    func hideSelectedRestaurant() {
        selectedRestaurantView.isHidden = true
        restaurantSearchButton.isHidden = false
        searchIconView.isHidden = false
        
        selectedRestaurantNameLabel.text = ""
        selectedRestaurantAddressLabel.text = ""
    }
}
