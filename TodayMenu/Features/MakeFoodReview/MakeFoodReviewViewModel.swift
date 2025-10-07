//
//  MakeFoodReviewViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

final class MakeFoodReviewViewModel {
    
    private let disposeBag = DisposeBag()
    private let selectedFood: FoodRecommendation
    private let menuSelectedTime: Date
    private let reviewRepository = ReviewRepository()
    private let foodRepository = FoodRepository()
    
    struct Input {
        let starTaps: [Observable<Void>]
        let tagTaps: [Observable<Void>]
        let photoUploadTap: Observable<Void>
        let saveTap: Observable<Void>
        let foodNameText: Observable<String>
        let storeNameText: Observable<String>
        let commentText: Observable<String>
        let companionText: Observable<String>
        let datePickerValueChanged: Observable<Date>
        let selectedRestaurant: Observable<RestaurantData?>
        let selectedPhotos: Observable<[UIImage]>
        let photoRemoveTap: Observable<Int>
    }
    
    struct Output {
        let initialData: Driver<FoodRecommendation>
        let initialEatTime: Driver<Date>
        let eatTimeDisplay: Driver<String>
        let starRatingUpdate: Driver<Int>
        let starRatingDisplay: Driver<String>
        let tagSelectionUpdate: Driver<Int>
        let showCompanionTextField: Driver<Bool>
        let companionTextFieldClear: Driver<Void>
        let validationResult: Driver<ValidationResult>
        let showImagePicker: Signal<Void>
        let showSaveSuccess: Signal<String>
        let showError: Signal<String>
        let popView: Signal<Void>
        let selectedPhotos: Driver<[UIImage]>
        let photoCount: Driver<String>
    }
    
    private let starRatingRelay = BehaviorRelay<Int>(value: 0)
    private let selectedTagRelay = BehaviorRelay<Int>(value: -1)
    private let eatTimeRelay = BehaviorRelay<Date>(value: Date())
    private let commentRelay = BehaviorRelay<String>(value: "")
    private let companionNameRelay = BehaviorRelay<String>(value: "")
    private let foodNameRelay = BehaviorRelay<String>(value: "")
    private let storeNameRelay = BehaviorRelay<String>(value: "")
    private let selectedRestaurantRelay = BehaviorRelay<RestaurantData?>(value: nil)
    private let selectedPhotosRelay = BehaviorRelay<[UIImage]>(value: [])
    
    init(selectedFood: FoodRecommendation, menuSelectedTime: Date = Date()) {
        self.selectedFood = selectedFood
        self.menuSelectedTime = menuSelectedTime
        
        let initialEatTime = calculateInitialEatTime()
        self.eatTimeRelay.accept(initialEatTime)
    }
    
    func transform(_ input: Input) -> Output {
        input.datePickerValueChanged
            .bind(to: eatTimeRelay)
            .disposed(by: disposeBag)
        
        input.commentText
            .bind(to: commentRelay)
            .disposed(by: disposeBag)
        
        input.companionText
            .bind(to: companionNameRelay)
            .disposed(by: disposeBag)
        
        input.foodNameText
            .bind(to: foodNameRelay)
            .disposed(by: disposeBag)
        
        input.storeNameText
            .bind(to: storeNameRelay)
            .disposed(by: disposeBag)
        
        input.selectedRestaurant
            .bind(to: selectedRestaurantRelay)
            .disposed(by: disposeBag)
        
        input.selectedPhotos
            .bind(to: selectedPhotosRelay)
            .disposed(by: disposeBag)
        
        input.photoRemoveTap
            .withLatestFrom(selectedPhotosRelay) { index, photos in
                var newPhotos = photos
                if index < newPhotos.count {
                    newPhotos.remove(at: index)
                }
                return newPhotos
            }
            .bind(to: selectedPhotosRelay)
            .disposed(by: disposeBag)
        
        let photoCount = selectedPhotosRelay
            .map { "\($0.count)/5" }
            .asDriver(onErrorJustReturn: "0/5")
        
        let eatTimeDisplay = eatTimeRelay
            .map { date in
                DateFormatter.formatDateToString(date: date, format: "yyyy년 M월 d일 a h시 mm분")
            }
            .asDriver(onErrorJustReturn: "")
        
        let starRating = Observable.merge(
            input.starTaps.enumerated().map { index, tap in
                tap.map { index + 1 }
            }
        )
        .do(onNext: { [weak self] rating in
            self?.starRatingRelay.accept(rating)
        })
        
        let starRatingDisplay = starRatingRelay
            .map { rating in
                if rating > 0 {
                    return "\(rating)점"
                } else {
                    return "별점을 선택해주세요"
                }
            }
            .asDriver(onErrorJustReturn: "별점을 선택해주세요")
        
        let tagSelection = Observable.merge(
            input.tagTaps.enumerated().map { index, tap in
                tap.map { index }
            }
        )
        .do(onNext: { [weak self] tagIndex in
            self?.selectedTagRelay.accept(tagIndex)
        })
        
        let showCompanionTextField = selectedTagRelay
            .map { tagIndex in
                return tagIndex >= 1
            }
            .asDriver(onErrorJustReturn: false)
        
        let companionTextFieldClear = selectedTagRelay
            .filter { $0 == 0 }
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let formData = Observable.combineLatest(
            input.foodNameText.startWith(selectedFood.title),
            input.storeNameText.startWith(""),
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
        
        let popAfterSave = saveSuccess.map { _ in () }
        let popView = popAfterSave
        
        let showImagePicker = input.photoUploadTap
            .withLatestFrom(selectedPhotosRelay)
            .filter { $0.count < 5 }
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())
        
        let photoLimitError = input.photoUploadTap
            .withLatestFrom(selectedPhotosRelay)
            .filter { $0.count >= 5 }
            .map { _ in "사진은 최대 5장까지 추가할 수 있습니다." }
            .asSignal(onErrorSignalWith: .empty())
        
        let allErrors = Signal.merge(saveError.asSignal(onErrorSignalWith: .empty()), photoLimitError)
        
        return Output(
            initialData: Driver.just(selectedFood),
            initialEatTime: Driver.just(eatTimeRelay.value),
            eatTimeDisplay: eatTimeDisplay,
            starRatingUpdate: starRating.asDriver(onErrorJustReturn: 0),
            starRatingDisplay: starRatingDisplay,
            tagSelectionUpdate: tagSelection.asDriver(onErrorJustReturn: -1),
            showCompanionTextField: showCompanionTextField,
            companionTextFieldClear: companionTextFieldClear,
            validationResult: validationResult.asDriver(onErrorJustReturn: ValidationResult(isValid: false)),
            showImagePicker: showImagePicker,
            showSaveSuccess: saveSuccess.asSignal(onErrorSignalWith: .empty()),
            showError: allErrors,
            popView: popView.asSignal(onErrorSignalWith: .empty()),
            selectedPhotos: selectedPhotosRelay.asDriver(),
            photoCount: photoCount
        )
    }
}

// MARK: - Logic
extension MakeFoodReviewViewModel {
    private func calculateInitialEatTime() -> Date {
        let oneHourLater = menuSelectedTime.addingTimeInterval(3600)
        let now = Date()
        return oneHourLater > now ? now : oneHourLater
    }
    
    private func validateForm(foodName: String, storeName: String, rating: Int, comment: String, taggedPeople: String) -> ValidationResult {
        if foodName.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "메뉴 이름을 입력해주세요")
        }
        
        if rating == 0 {
            return ValidationResult(isValid: false, errorMessage: "별점을 선택해주세요")
        }
        
        return ValidationResult(isValid: true)
    }
    
    private func saveReview() -> Observable<Result<String, Error>> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onNext(.failure(ReviewError.validationFailed("오류가 발생했습니다")))
                observer.onCompleted()
                return Disposables.create()
            }
            
            // FoodRepository를 사용하여 FoodReview 생성
            let foodReview = self.foodRepository.createFoodReview(
                name: self.selectedFood.title,
                cuisine: self.selectedFood.cuisine,
                category: self.selectedFood.category
            )
            
            // Restaurant 객체 생성
            let restaurant: Restaurant?
            if let selectedRestaurant = self.selectedRestaurantRelay.value {
                let latitude = Double(selectedRestaurant.latitude) ?? 0.0
                let longitude = Double(selectedRestaurant.longitude) ?? 0.0
                
                restaurant = Restaurant(
                    name: selectedRestaurant.restaurantName,
                    latitude: latitude,
                    longitude: longitude,
                    cuisine: selectedRestaurant.categoryName,
                    restaurantId: selectedRestaurant.restaurantId
                )
            } else {
                restaurant = nil
            }
            
            // Companion 객체 생성
            var companions: [Companion] = []
            if self.selectedTagRelay.value >= 0 && self.selectedTagRelay.value < CompanionType.allCases.count {
                let companionType = CompanionType.allCases[self.selectedTagRelay.value]
                let companionName = self.companionNameRelay.value
                
                if companionType == .alone {
                    let companion = Companion(type: .alone, name: nil)
                    companions.append(companion)
                } else {
                    let name = companionName.isEmpty ? nil : companionName
                    let companion = Companion(type: companionType, name: name)
                    companions.append(companion)
                }
            }
            
            // Review 객체 생성 (사진 없이)
            // Review 객체 생성
            let review = Review(
                food: [foodReview],
                restaurant: restaurant,
                rating: Double(self.starRatingRelay.value),
                comment: self.commentRelay.value.isEmpty ? nil : self.commentRelay.value,
                companion: companions,
                photos: [],
                ateAt: self.eatTimeRelay.value
            )
            
            // Review 저장
            self.reviewRepository.saveReview(review)
                .subscribe(onNext: { result in
                    switch result {
                    case .success:
                        // Review ID를 사용하여 사진 저장
                        let reviewId = review.id.stringValue
                        let selectedImages = self.selectedPhotosRelay.value
                        let photoFileNames = ImageStorageManager.shared.saveReviewImages(selectedImages, reviewId: reviewId)
                        
                        // 사진 파일명을 Review에 업데이트
                        do {
                            let realm = try Realm()
                            try realm.write {
                                review.photos.append(objectsIn: photoFileNames)
                            }

                            // RecommendHistory의 reviewId 업데이트 (있는 경우만)
                            if let recommendHistoryId = self.selectedFood.recommendHistoryId {
                                self.reviewRepository.updateRecommendHistoryReviewId(
                                    recommendHistoryId: recommendHistoryId,
                                    reviewId: review.id
                                )
                                .subscribe(onNext: { result in
                                    switch result {
                                    case .success:
                                        print("RecommendHistory와 Review 연결 완료")
                                    case .failure(let error):
                                        print("RecommendHistory 업데이트 실패: \(error)")
                                    }
                                })
                                .disposed(by: self.disposeBag)
                            }

                            observer.onNext(.success("리뷰가 저장되었습니다!"))
                        } catch {
                            observer.onNext(.failure(ReviewError.saveFailed("사진 저장 중 오류가 발생했습니다")))
                        }
                        observer.onCompleted()
                        
                    case .failure(let error):
                        observer.onNext(.failure(error))
                        observer.onCompleted()
                    }
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
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
