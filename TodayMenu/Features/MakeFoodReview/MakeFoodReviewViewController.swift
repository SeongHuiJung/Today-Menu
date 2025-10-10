//
//  MakeFoodReviewViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI
import AVFoundation

final class MakeFoodReviewViewController: BaseViewController {
    
    private let mainView = MakeFoodReviewView()
    private let viewModel: MakeFoodReviewViewModel
    private let disposeBag = DisposeBag()
    private let menuSelectedTime: Date
    
    // 선택된 식당 정보
    private var selectedRestaurant: RestaurantData?
    private let selectedRestaurantRelay = BehaviorRelay<RestaurantData?>(value: nil)
    
    // 선택된 사진들
    private let selectedImagesRelay = BehaviorRelay<[UIImage]>(value: [])

    // 선택된 카테고리 (Calendar에서만 사용)
    private let selectedCategoryRelay = BehaviorRelay<String?>(value: nil)

    private let saveButton: UIButton? = nil
    
    init(food: FoodRecommendation, menuSelectedTime: Date = Date()) {
        self.viewModel = MakeFoodReviewViewModel(selectedFood: food, menuSelectedTime: menuSelectedTime)
        self.menuSelectedTime = menuSelectedTime
        super.init(nibName: nil, bundle: nil)
    }

    // Calendar에서 온 경우
    init(viewModel: MakeFoodReviewViewModel, selectedDate: Date) {
        self.viewModel = viewModel
        self.menuSelectedTime = selectedDate
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupRestaurantSearchButton()
        setupRemoveRestaurantButton()
        setupCategorySettingButton()
        bind()
    }
    
    override func configureView() {
        super.configureView()
        title = "새 리뷰"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

// MARK: - Setup
extension MakeFoodReviewViewController {
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.fontBlack]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .fontBlack
    }
    
    private func setupRestaurantSearchButton() {
        mainView.restaurantSearchButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.presentRestaurantSearch()
            }
            .disposed(by: disposeBag)
    }
    
    private func setupRemoveRestaurantButton() {
        mainView.removeRestaurantButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.selectedRestaurant = nil
                owner.selectedRestaurantRelay.accept(nil)
                owner.mainView.hideSelectedRestaurant()
            }
            .disposed(by: disposeBag)
    }

    private func setupCategorySettingButton() {
        mainView.categorySettingButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.presentCategorySelection()
            }
            .disposed(by: disposeBag)
    }

    private func presentCategorySelection() {
        let categoryVC = CategorySelectionViewController()

        // 카테고리 선택 콜백 설정
        categoryVC.onCategorySelected = { [weak self] cuisine, category in
            guard let self else { return }
            let displayText = "\(cuisine) > \(category)"
            mainView.updateCategoryButtonTitle(displayText)

            // foodNameTextField의 placeholder에 중분류 이름(category) 표시
            mainView.foodNameTextField.placeholder = category

            // 선택된 카테고리를 Relay에 저장
            selectedCategoryRelay.accept(displayText)
        }

        navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    private func presentRestaurantSearch() {
        let searchVC = RestaurantSearchViewController()
        searchVC.modalPresentationStyle = .fullScreen
        
        // 식당 선택 콜백 설정
        searchVC.onRestaurantSelected = { [weak self] restaurant in
            self?.selectedRestaurant = restaurant
            self?.selectedRestaurantRelay.accept(restaurant)
            self?.mainView.showSelectedRestaurant(restaurant)
        }
        
        present(searchVC, animated: true)
    }
}

// MARK: - Bind
extension MakeFoodReviewViewController {
    private func bind() {
        let starTaps = mainView.starButtons.map { $0.rx.tap.asObservable() }
        let tagTaps = mainView.tagButtons.map { $0.rx.tap.asObservable() }
        
        // 사진 삭제 이벤트
        let photoRemoveSubject = PublishSubject<Int>()
        
        mainView.datePickerButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.mainView.toggleDatePicker()
            }
            .disposed(by: disposeBag)
        
        let input = MakeFoodReviewViewModel.Input(
            starTaps: starTaps,
            tagTaps: tagTaps,
            photoUploadTap: mainView.photoCaptureButton.rx.tap.asObservable(),
            saveTap: mainView.saveButton.rx.tap.asObservable(),
            foodNameText: mainView.foodNameTextField.rx.text.orEmpty.asObservable(),
            storeNameText: Observable.just(""),
            commentText: mainView.commentTextView.rx.text.orEmpty.asObservable(),
            companionText: mainView.companionTextField.rx.text.orEmpty.asObservable(),
            datePickerValueChanged: mainView.datePicker.rx.value.skip(1).asObservable(),
            selectedRestaurant: selectedRestaurantRelay.asObservable(),
            selectedPhotos: selectedImagesRelay.asObservable(),
            photoRemoveTap: photoRemoveSubject.asObservable(),
            selectedCategory: selectedCategoryRelay.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        // 선택된 사진 CollectionView 바인딩
        output.selectedPhotos
            .drive(mainView.selectedPhotosCollectionView.rx.items(
                cellIdentifier: PhotoCollectionViewCell.identifier,
                cellType: PhotoCollectionViewCell.self
            )) { index, image, cell in
                cell.configure(with: image)
                cell.onRemove = {
                    photoRemoveSubject.onNext(index)
                }
            }
            .disposed(by: disposeBag)
        
        // 사진 개수 업데이트
        output.photoCount
            .drive(onNext: { [weak self] count in
                let components = count.split(separator: "/")
                if let current = components.first, let max = components.last {
                    self?.mainView.photoCaptureButton.updateCount(
                        current: Int(current) ?? 0,
                        max: Int(max) ?? 5
                    )
                }
            })
            .disposed(by: disposeBag)
        
        output.initialData
            .drive(onNext: { [weak self] food in
                self?.mainView.populateInitialData(foodName: food.title, placeholder: food.title == "" ? "먹은 음식" : food.title, storeName: "")
            })
            .disposed(by: disposeBag)

        // Calendar에서 온 경우 음식 분류 설정 버튼 표시
        if output.isFromCalendar {
            mainView.showCategorySettingButton()
        }
        
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
        
        // 사진 추가 버튼 탭 시, 최대 개수 체크 후 이미지 피커 표시
        output.showImagePicker
            .emit(with: self) { owner, _ in
                owner.presentImagePicker()
            }
            .disposed(by: disposeBag)
        
        output.showSaveSuccess
            .emit(with: self) { owner, message in
                let alert = AlertManager.shared.makeInfoAlertWithPop(title: "리뷰 작성 성공", message: message)
                // 확인 버튼 탭 시 네비게이션 pop
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                    owner.navigationController?.popViewController(animated: true)
                })
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
        let currentCount = selectedImagesRelay.value.count
        
        // 커스텀 갤러리 표시
        let galleryVC = CustomPhotoGalleryViewController(existingPhotoCount: currentCount)
        galleryVC.modalPresentationStyle = .fullScreen
        
        galleryVC.onPhotosSelected = { [weak self] images in
            guard let self = self else { return }
            var currentImages = self.selectedImagesRelay.value
            
            for image in images {
                if currentImages.count < 5 {
                    currentImages.append(image)
                }
            }
            
            self.selectedImagesRelay.accept(currentImages)
        }
        
        present(galleryVC, animated: true)
    }
}
