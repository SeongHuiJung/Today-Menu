//
//  MakeFoodReviewViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MakeFoodReviewViewController: BaseViewController {
    
    private let mainView = MakeFoodReviewView()
    private let viewModel: MakeFoodReviewViewModel
    private let disposeBag = DisposeBag()
    private let menuSelectedTime: Date
    
    private let saveButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return button
    }()
    
    init(food: FoodRecommendation, menuSelectedTime: Date = Date()) {
        self.viewModel = MakeFoodReviewViewModel(selectedFood: food, menuSelectedTime: menuSelectedTime)
        self.menuSelectedTime = menuSelectedTime
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupRestaurantSearchButton()
        bind()
    }
    
    override func configureView() {
        super.configureView()
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        title = "새 리뷰"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

// MARK: - Setup
extension MakeFoodReviewViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .point
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    private func setupRestaurantSearchButton() {
        mainView.restaurantSearchButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.presentRestaurantSearch()
            }
            .disposed(by: disposeBag)
    }
    
    private func presentRestaurantSearch() {
        let searchVC = RestaurantSearchViewController()
        searchVC.modalPresentationStyle = .fullScreen
        present(searchVC, animated: true)
    }
}

// MARK: - Bind
extension MakeFoodReviewViewController {
    private func bind() {
        let starTaps = mainView.starButtons.map { $0.rx.tap.asObservable() }
        let tagTaps = mainView.tagButtons.map { $0.rx.tap.asObservable() }
        
        let photoUploadTapGesture = UITapGestureRecognizer()
        mainView.photoUploadView.addGestureRecognizer(photoUploadTapGesture)
        let photoUploadTap = photoUploadTapGesture.rx.event
            .map { _ in () }
            .asObservable()
        
        mainView.datePickerButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.mainView.toggleDatePicker()
            }
            .disposed(by: disposeBag)
        
        let input = MakeFoodReviewViewModel.Input(
            starTaps: starTaps,
            tagTaps: tagTaps,
            photoUploadTap: photoUploadTap,
            saveTap: saveButton.rx.tap.asObservable(),
            foodNameText: mainView.foodNameTextField.rx.text.orEmpty.asObservable(),
            storeNameText: Observable.just(""), // 검색 버튼으로 대체
            commentText: mainView.commentTextView.rx.text.orEmpty.asObservable(),
            companionText: mainView.companionTextField.rx.text.orEmpty.asObservable(),
            datePickerValueChanged: mainView.datePicker.rx.value.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        output.initialData
            .drive(with: self) { owner, food in
                owner.mainView.populateInitialData(foodName: food.title, storeName: food.place)
            }
            .disposed(by: disposeBag)
        
        output.initialEatTime
            .drive(with: self) { owner, date in
                owner.mainView.setDatePickerDate(date)
            }
            .disposed(by: disposeBag)
        
        output.eatTimeDisplay
            .drive(with: self) { owner, dateString in
                owner.mainView.updateDateDisplay(dateString)
            }
            .disposed(by: disposeBag)
        
        output.starRatingUpdate
            .drive(with: self) { owner, rating in
                owner.mainView.updateStarRating(rating)
            }
            .disposed(by: disposeBag)
        
        output.starRatingDisplay
            .drive(with: self) { owner, text in
                let isHighlighted = !text.contains("선택")
                owner.mainView.updateStarRatingDisplay(text, isHighlighted: isHighlighted)
            }
            .disposed(by: disposeBag)
        
        output.tagSelectionUpdate
            .drive(with: self) { owner, tagIndex in
                owner.mainView.selectTag(at: tagIndex)
            }
            .disposed(by: disposeBag)
        
        output.showCompanionTextField
            .skip(1)
            .drive(with: self) { owner, shouldShow in
                if shouldShow {
                    owner.mainView.showCompanionTextField()
                } else {
                    owner.mainView.hideCompanionTextField()
                }
            }
            .disposed(by: disposeBag)
        
        output.companionTextFieldClear
            .drive(with: self) { owner, _ in
                owner.mainView.clearCompanionTextField()
            }
            .disposed(by: disposeBag)
        
        output.validationResult
            .drive()
            .disposed(by: disposeBag)
        
        output.showImagePicker
            .emit(with: self) { owner, _ in
                owner.presentImagePicker()
            }
            .disposed(by: disposeBag)
        
        output.showSaveSuccess
            .emit(with: self) { owner, message in
                let alert = AlertManager.shared.makeInfoAlert(title: "성공", message: message)
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.showError
            .emit(with: self) { owner, message in
                let alert = AlertManager.shared.makeInfoAlert(title: "오류", message: message)
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.popView
            .emit(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Image Picker
extension MakeFoodReviewViewController {
    private func presentImagePicker() {
        let alert = UIAlertController(title: "사진 선택", message: "사진을 선택하는 방법을 선택해주세요", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "카메라", style: .default) { _ in
            // TODO: Present camera
            print("카메라 기능")
        })
        
        alert.addAction(UIAlertAction(title: "갤러리", style: .default) { _ in
            // TODO: Present photo library
            print("갤러리 기능")
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
}


