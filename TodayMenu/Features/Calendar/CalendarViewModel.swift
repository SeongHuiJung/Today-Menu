//
//  CalendarViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 10/2/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CalendarViewModel {
    
    private let disposeBag = DisposeBag()
    private let repository: ReviewRepository
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let dateSelected: Observable<Date>
        let weekDateSelected: Observable<Date>
        let reviewSelected: Observable<Review>
        let calendarBackTapped: Observable<Void>
    }
    
    struct Output {
        let reviewsByDate: Driver<[String: [Review]]>
        let currentReviews: Driver<[Review]>
        let weekDates: Driver<[Date]>
        let selectedDate: Driver<Date?>
        let oldestReviewDate: Driver<Date?>
        let shouldHideCalendar: Driver<Date>
        let shouldShowCalendar: Driver<Void>
        let dateLabels: Driver<(year: String, month: String)>
        let reviewDetailTrigger: Driver<Review>
    }
    
    private let reviewsByDateRelay = BehaviorRelay<[String: [Review]]>(value: [:])
    private let currentReviewsRelay = BehaviorRelay<[Review]>(value: [])
    private let weekDatesRelay = BehaviorRelay<[Date]>(value: [])
    private let selectedDateRelay = BehaviorRelay<Date?>(value: nil)
    private let oldestReviewDateRelay = BehaviorRelay<Date?>(value: nil)
    
    init(repository: ReviewRepository = ReviewRepository()) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        // 리뷰 데이터 로드
        let reviews = input.viewWillAppear
            .flatMapLatest { [weak self] _ -> Observable<[Review]> in
                guard let self = self else { return .empty() }
                return self.repository.fetchAllReviews()
            }
            .share()
        
        // 리뷰를 날짜별로 정리
        reviews
            .map { [weak self] reviews -> [String: [Review]] in
                self?.organizeReviewsByDate(reviews) ?? [:]
            }
            .bind(to: reviewsByDateRelay)
            .disposed(by: disposeBag)
        
        // 가장 오래된 리뷰 날짜 저장
        reviews
            .map { reviews -> Date? in
                reviews.map { $0.ateAt }.min()
            }
            .bind(to: oldestReviewDateRelay)
            .disposed(by: disposeBag)
        
        // 캘린더에서 날짜 선택 시 처리
        let calendarDateSelected = input.dateSelected
            .withLatestFrom(reviewsByDateRelay) { date, reviewsByDate -> Date? in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateKey = dateFormatter.string(from: date)
                
                // 해당 날짜에 리뷰가 있을 경우에만 날짜 반환
                return reviewsByDate[dateKey] != nil ? date : nil
            }
            .compactMap { $0 }
        
        // 캘린더 숨김 트리거
        let shouldHideCalendar = calendarDateSelected
            .do(onNext: { [weak self] date in
                self?.selectedDateRelay.accept(date)
                self?.updateWeekDates(around: date)
            })
            .asDriver(onErrorJustReturn: Date())
        
        // 주간 뷰에서 날짜 선택 시 처리
        input.weekDateSelected
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                self.selectedDateRelay.accept(date)
                self.updateCurrentReviews(for: date)
            })
            .disposed(by: disposeBag)
        
        // 캘린더 다시 보기
        let shouldShowCalendar = input.calendarBackTapped
            .do(onNext: { [weak self] in
                self?.selectedDateRelay.accept(nil)
            })
            .asDriver(onErrorJustReturn: ())
        
        // 날짜 라벨 업데이트
        let dateLabels = selectedDateRelay
            .compactMap { $0 }
            .map { date -> (year: String, month: String) in
                let year = Calendar.current.component(.year, from: date)
                let month = Calendar.current.component(.month, from: date)
                return (year: "\(year)년", month: "\(month)월")
            }
            .asDriver(onErrorJustReturn: (year: "", month: ""))
        
        // 리뷰 상세보기 트리거
        let reviewDetailTrigger = input.reviewSelected
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            reviewsByDate: reviewsByDateRelay.asDriver(),
            currentReviews: currentReviewsRelay.asDriver(),
            weekDates: weekDatesRelay.asDriver(),
            selectedDate: selectedDateRelay.asDriver(),
            oldestReviewDate: oldestReviewDateRelay.asDriver(),
            shouldHideCalendar: shouldHideCalendar,
            shouldShowCalendar: shouldShowCalendar,
            dateLabels: dateLabels,
            reviewDetailTrigger: reviewDetailTrigger
        )
    }
}

// MARK: - Private Methods
private extension CalendarViewModel {
    
    func organizeReviewsByDate(_ reviews: [Review]) -> [String: [Review]] {
        var result: [String: [Review]] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for review in reviews {
            let dateKey = dateFormatter.string(from: review.ateAt)
            if result[dateKey] == nil {
                result[dateKey] = []
            }
            result[dateKey]?.append(review)
        }
        
        return result
    }
    
    func updateCurrentReviews(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: date)
        
        let reviews = reviewsByDateRelay.value[dateKey] ?? []
        let sortedReviews = reviews.sorted { $0.ateAt < $1.ateAt }
        currentReviewsRelay.accept(sortedReviews)
    }
    
    func updateWeekDates(around date: Date) {
        let dates = generateWeekDates(around: date)
        weekDatesRelay.accept(dates)
        updateCurrentReviews(for: date)
    }
    
    func generateWeekDates(around date: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        var dates: [Date] = []
        
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        guard let twoDaysLater = calendar.date(byAdding: .day, value: 2, to: today) else {
            return []
        }
        
        let startDate = oldestReviewDateRelay.value ?? calendar.date(byAdding: .month, value: -3, to: today) ?? today
        
        var currentDate = calendar.startOfDay(for: startDate)
        
        while currentDate <= twoDaysLater {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
}
