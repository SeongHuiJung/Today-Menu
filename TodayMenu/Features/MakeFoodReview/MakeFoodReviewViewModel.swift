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
    private let menuSelectedTime: Date
    private let repository = ReviewRepository()
    
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
    }
    
    private let starRatingRelay = BehaviorRelay<Int>(value: 0)
    private let selectedTagRelay = BehaviorRelay<Int>(value: -1)
    private let eatTimeRelay = BehaviorRelay<Date>(value: Date())
    private let commentRelay = BehaviorRelay<String>(value: "")
    private let companionNameRelay = BehaviorRelay<String>(value: "")
    private let foodNameRelay = BehaviorRelay<String>(value: "")
    private let storeNameRelay = BehaviorRelay<String>(value: "")
    private let selectedRestaurantRelay = BehaviorRelay<RestaurantData?>(value: nil)
    
    init(selectedFood: FoodRecommendation, menuSelectedTime: Date = Date()) {
        self.selectedFood = selectedFood
        self.menuSelectedTime = menuSelectedTime
        
        // 초기 먹은 시간 설정
        let initialEatTime = calculateInitialEatTime()
        self.eatTimeRelay.accept(initialEatTime)
    }
    
    func transform(_ input: Input) -> Output {
        // 먹은 시간 처리
        input.datePickerValueChanged
            .bind(to: eatTimeRelay)
            .disposed(by: disposeBag)
        
        // 코멘트 처리
        input.commentText
            .bind(to: commentRelay)
            .disposed(by: disposeBag)
        
        // 동행인 이름 처리
        input.companionText
            .bind(to: companionNameRelay)
            .disposed(by: disposeBag)
        
        // 음식 이름 처리
        input.foodNameText
            .bind(to: foodNameRelay)
            .disposed(by: disposeBag)
        
        // 식당 이름 처리
        input.storeNameText
            .bind(to: storeNameRelay)
            .disposed(by: disposeBag)
        
        // 선택된 식당 정보 처리
        input.selectedRestaurant
            .bind(to: selectedRestaurantRelay)
            .disposed(by: disposeBag)
        
        let eatTimeDisplay = eatTimeRelay
            .map { date in
                DateFormatter.formatDateToString(date: date, format: "yyyy년 M월 d일 a h시 mm분")
            }
            .asDriver(onErrorJustReturn: "")
        
        // 별점 핸들링
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
        
        // 동행인 태그 핸들링
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
                return tagIndex >= 1 // '혼자' 가 아닌 다른 태그 선택시
            }
            .asDriver(onErrorJustReturn: false)
        
        let companionTextFieldClear = selectedTagRelay
            .filter { $0 == 0 } // "혼자" 선택 시
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
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
            initialEatTime: Driver.just(eatTimeRelay.value),
            eatTimeDisplay: eatTimeDisplay,
            starRatingUpdate: starRating.asDriver(onErrorJustReturn: 0),
            starRatingDisplay: starRatingDisplay,
            tagSelectionUpdate: tagSelection.asDriver(onErrorJustReturn: -1),
            showCompanionTextField: showCompanionTextField,
            companionTextFieldClear: companionTextFieldClear,
            validationResult: validationResult.asDriver(onErrorJustReturn: ValidationResult(isValid: false)),
            showImagePicker: input.photoUploadTap.asSignal(onErrorSignalWith: .empty()),
            showSaveSuccess: saveSuccess.asSignal(onErrorSignalWith: .empty()),
            showError: saveError.asSignal(onErrorSignalWith: .empty()),
            popView: popView.asSignal(onErrorSignalWith: .empty())
        )
    }
}

// MARK: - Logic
extension MakeFoodReviewViewModel {
    private func calculateInitialEatTime() -> Date {
        // 메뉴 선택 시간 + 1시간
        let oneHourLater = menuSelectedTime.addingTimeInterval(3600)
        let now = Date()
        
        // 1시간 후가 현재 시간보다 미래라면 현재 시간 사용
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
            
            // Food 객체 생성
            let foodName = self.foodNameRelay.value.isEmpty ? self.selectedFood.title : self.foodNameRelay.value
            let food = Food(
                name: foodName,
                cuisine: self.selectedFood.cuisine, // 대분류 (한식/중식/일식)
                category: self.selectedFood.category // 중분류 (피자/돈까스/초밥)
            )
            
            // Restaurant 객체 생성
            let restaurant: Restaurant?
            
            // 선택된 식당 정보가 있으면 사용
            if let selectedRestaurant = self.selectedRestaurantRelay.value {
                let latitude = Double(selectedRestaurant.latitude) ?? 0.0
                let longitude = Double(selectedRestaurant.longitude) ?? 0.0
                
                restaurant = Restaurant(
                    name: selectedRestaurant.restaurantName,
                    latitude: latitude,
                    longitude: longitude,
                    cuisine: "korean",
                    restaurantId: selectedRestaurant.restaurantId
                )
            }
            // 선택된 식당 정보가 없으면 식당 정보를 저장하지 않음
            else {
                restaurant = nil
            }
            
            // Companion 객체 생성
            var companions: [Companion] = []
            if self.selectedTagRelay.value >= 0 && self.selectedTagRelay.value < CompanionType.allCases.count {
                let companionType = CompanionType.allCases[self.selectedTagRelay.value]
                let companionName = self.companionNameRelay.value
                
                // 혼자 태그 선택 시: name 없이 type만 저장
                if companionType == .alone {
                    let companion = Companion(type: .alone, name: nil)
                    companions.append(companion)
                }
                // 다른 태그 선택 시: name이 비어있어도 type은 저장
                else {
                    let name = companionName.isEmpty ? nil : companionName
                    let companion = Companion(type: companionType, name: name)
                    companions.append(companion)
                }
            }
            
            // Review 객체 생성
            let review = Review(
                food: [food],
                restaurant: restaurant,
                rating: Double(self.starRatingRelay.value),
                comment: self.commentRelay.value.isEmpty ? nil : self.commentRelay.value,
                companion: companions,
                photos: [], // TODO: 사진 기능 추가 시 구현
                ateAt: self.eatTimeRelay.value
            )
            
            // Realm에 저장
            self.repository.saveReview(review)
                .subscribe(onNext: { result in
                    switch result {
                    case .success:
                        observer.onNext(.success("리뷰가 저장되었습니다!"))
                    case .failure(let error):
                        observer.onNext(.failure(error))
                    }
                    observer.onCompleted()
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
