//
//  MakeFoodReviewViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MakeFoodReviewViewModel {
    
    private let disposeBag = DisposeBag()
    private let selectedFood: FoodRecommendation
    
    struct Input {
        let starTaps: [Observable<Void>]
        let tagTaps: [Observable<Void>]
        let photoUploadTap: Observable<Void>
        let saveTap: Observable<Void>
        let foodNameText: Observable<String>
        let storeNameText: Observable<String>
        let commentText: Observable<String>
        let companionText: Observable<String>
    }
    
    struct Output {
        let initialData: Driver<FoodRecommendation>
        let starRatingUpdate: Driver<Int>
        let tagSelectionUpdate: Driver<Int>
        let validationResult: Driver<ValidationResult>
        let showImagePicker: Signal<Void>
        let showSaveSuccess: Signal<String>
        let showError: Signal<String>
        let popView: Signal<Void>
    }
    
    private let starRatingRelay = BehaviorRelay<Int>(value: 0)
    private let selectedTagRelay = BehaviorRelay<Int>(value: -1)
    
    init(selectedFood: FoodRecommendation) {
        self.selectedFood = selectedFood
    }
    
    func transform(_ input: Input) -> Output {
        // 별점 핸들링
        let starRating = Observable.merge(
            input.starTaps.enumerated().map { index, tap in
                tap.map { index + 1 }
            }
        )
        .do(onNext: { [weak self] rating in
            guard let self else { return }
            starRatingRelay.accept(rating)
        })
        
        // 동행인 태그 핸들링
        let tagSelection = Observable.merge(
            input.tagTaps.enumerated().map { index, tap in
                tap.map { index }
            }
        )
        .do(onNext: { [weak self] tagIndex in
            guard let self else { return }
            selectedTagRelay.accept(tagIndex)
        })
        
        let formData = Observable.combineLatest(
            input.foodNameText.startWith(selectedFood.title),
            input.storeNameText.startWith(selectedFood.place),
            starRatingRelay.asObservable(),
            input.commentText.startWith(""),
            input.companionText.startWith("")
        )
        
        let validationResult = formData
            .map { [weak self] foodName, storeName, rating, comment, taggedPeople in
                self?.validateForm(
                    foodName: foodName,
                    storeName: storeName,
                    rating: rating,
                    comment: comment,
                    taggedPeople: taggedPeople
                ) ?? ValidationResult(isValid: false, errorMessage: "입력을 확인해주세요")
            }
        
        // Save review
        let saveResult = input.saveTap
            .withLatestFrom(validationResult)
            .flatMap { [weak self] validation -> Observable<Result<String, Error>> in
                guard let self = self else {
                    return Observable.just(.failure(ReviewError.validationFailed("오류가 발생했습니다")))
                }
                
                if validation.isValid {
                    return self.saveReview()
                } else {
                    return Observable.just(.failure(ReviewError.validationFailed(validation.errorMessage ?? "입력을 확인해주세요")))
                }
            }
            .share()
        
        let saveSuccess = saveResult
            .compactMap { result in
                if case .success(let message) = result {
                    return message
                } else {
                    return nil
                }
            }
        
        let saveError = saveResult
            .compactMap { result in
                if case .failure(let error) = result {
                    if let reviewError = error as? ReviewError {
                        switch reviewError {
                        case .validationFailed(let message):
                            return message
                        case .saveFailed(let message):
                            return message
                        }
                    } else {
                        return error.localizedDescription
                    }
                } else {
                    return nil
                }
            }
        
        // Dismiss after successful save
        let popAfterSave = saveSuccess.map { _ in () }
        let popView = popAfterSave
        
        return Output(
            initialData: Driver.just(selectedFood),
            starRatingUpdate: starRating.asDriver(onErrorJustReturn: 0),
            tagSelectionUpdate: tagSelection.asDriver(onErrorJustReturn: -1),
            validationResult: validationResult.asDriver(onErrorJustReturn: ValidationResult(isValid: false)),
            showImagePicker: input.photoUploadTap.asSignal(onErrorSignalWith: .empty()),
            showSaveSuccess: saveSuccess.asSignal(onErrorSignalWith: .empty()),
            showError: saveError.asSignal(onErrorSignalWith: .empty()),
            popView: popView.asSignal(onErrorSignalWith: .empty())
        )
    }
}

// MARK: - Private Methods
extension MakeFoodReviewViewModel {
    private func validateForm(foodName: String, storeName: String, rating: Int, comment: String, taggedPeople: String) -> ValidationResult {
        if foodName.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "메뉴 이름을 입력해주세요")
        }
        
        if rating == 0 {
            return ValidationResult(isValid: false, errorMessage: "별점을 선택해주세요")
        }
        
        // 메뉴 이름, 별점, 방문 시간만 필수 (방문 시간은 기본값이 있으므로 챍하지 않음)
        
        return ValidationResult(isValid: true)
    }
    
    private func saveReview() -> Observable<Result<String, Error>> {
        // TODO: Implement actual save logic
        return Observable.just(.success("리뷰가 저장되었습니다!"))
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
    }
}

// MARK: - Models
struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
    
    init(isValid: Bool, errorMessage: String? = nil) {
        self.isValid = isValid
        self.errorMessage = errorMessage
    }
}

enum ReviewError: LocalizedError {
    case validationFailed(String)
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return message
        case .saveFailed(let message):
            return message
        }
    }
    
    var localizedDescription: String {
        return errorDescription ?? "알 수 없는 오류가 발생했습니다"
    }
}
