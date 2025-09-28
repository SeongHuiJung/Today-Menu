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
    
    private let saveButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return button
    }()
    
    init(food: FoodRecommendation) {
        self.viewModel = MakeFoodReviewViewModel(selectedFood: food)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
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
        
        let input = MakeFoodReviewViewModel.Input(
            starTaps: starTaps,
            tagTaps: tagTaps,
            photoUploadTap: photoUploadTap,
            saveTap: saveButton.rx.tap.asObservable(),
            foodNameText: mainView.foodNameTextField.rx.text.orEmpty.asObservable(),
            storeNameText: mainView.storeNameTextField.rx.text.orEmpty.asObservable(),
            commentText: mainView.commentTextView.rx.text.orEmpty.asObservable(),
            companionText: mainView.companionTextField.rx.text.orEmpty.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        output.initialData
            .drive(with: self) { owner, food in
                owner.mainView.populateData(with: food)
            }
            .disposed(by: disposeBag)
        
        output.starRatingUpdate
            .drive(with: self) { owner, rating in
                owner.mainView.updateStarRating(rating)
            }
            .disposed(by: disposeBag)
        
        output.tagSelectionUpdate
            .drive(with: self) { owner, tagIndex in
                owner.mainView.selectTag(at: tagIndex)
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
