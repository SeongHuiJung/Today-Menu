//
//  CalendarViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import UIKit
import FSCalendar
import SnapKit
import RxSwift

class CalendarViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let repository = ReviewRepository()
    
    private let calendarContainerView = UIView()
    
    private let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.backgroundColor = .clear
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.placeholderType = .none
        calendar.headerHeight = 60
        calendar.weekdayHeight = 40
        
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = .systemFont(ofSize: FontSize.subTitle, weight: .bold)
        calendar.appearance.headerDateFormat = "yyyy년 M월"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.weekdayFont = .systemFont(ofSize: FontSize.small, weight: .bold)
        
        calendar.appearance.titleDefaultColor = .clear
        calendar.appearance.titleWeekendColor = .clear
        calendar.appearance.titleTodayColor = .clear
        calendar.appearance.titleSelectionColor = .clear
        
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
        calendar.appearance.borderRadius = 0
        
        return calendar
    }()
    
    private var reviewsByDate: [String: [Review]] = [:]
    private var isCalendarHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        loadReviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReviews()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        view.addSubview(calendarContainerView)
        calendarContainerView.addSubview(calendar)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        calendarContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        calendar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func configureView() {
        super.configureView()
        view.backgroundColor = .backgroundGray
        title = "음식 History"
    }
    
    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.register(CalendarReviewCell.self, forCellReuseIdentifier: "reviewCell")
        calendar.register(CalendarEmptyCell.self, forCellReuseIdentifier: "emptyCell")
    }
    
    private func loadReviews() {
        repository.fetchAllReviews()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reviews in
                self?.organizeReviewsByDate(reviews)
                self?.calendar.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func organizeReviewsByDate(_ reviews: [Review]) {
        reviewsByDate.removeAll()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for review in reviews {
            let dateKey = dateFormatter.string(from: review.ateAt)
            if reviewsByDate[dateKey] == nil {
                reviewsByDate[dateKey] = []
            }
            reviewsByDate[dateKey]?.append(review)
        }
    }
    
    private func getReviews(for date: Date) -> [Review] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: date)
        return reviewsByDate[dateKey] ?? []
    }
    
    private func hideCalendar() {
        guard !isCalendarHidden else { return }
        isCalendarHidden = true
        
        calendarContainerView.snp.remakeConstraints {
            $0.bottom.equalTo(view.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(calendarContainerView.frame.height)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showCalendar() {
        guard isCalendarHidden else { return }
        isCalendarHidden = false
        
        calendarContainerView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - FSCalendarDataSource

extension CalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let reviews = getReviews(for: date)
        
        if !reviews.isEmpty {
            let cell = calendar.dequeueReusableCell(withIdentifier: "reviewCell", for: date, at: position) as! CalendarReviewCell
            
            let day = Calendar.current.component(.day, from: date)
            let firstReview = reviews.first!
            let foodName = firstReview.food.first?.name ?? "음식"
            let photoPath = firstReview.photos.first
            let additionalCount = reviews.count - 1
            
            cell.configure(date: day, foodName: foodName, photoPath: photoPath, additionalReviewCount: additionalCount)
            
            return cell
        } else {
            let cell = calendar.dequeueReusableCell(withIdentifier: "emptyCell", for: date, at: position) as! CalendarEmptyCell
            
            let day = Calendar.current.component(.day, from: date)
            let weekday = Calendar.current.component(.weekday, from: date)
            let isWeekend = weekday == 1 || weekday == 7
            
            cell.configure(date: day, isWeekend: isWeekend)
            
            return cell
        }
    }
}

// MARK: - FSCalendarDelegate

extension CalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let reviews = getReviews(for: date)
        
        if !reviews.isEmpty {
            print("선택된 날짜: \(date), 리뷰 개수: \(reviews.count)")
            hideCalendar()
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints {
            $0.height.equalTo(bounds.height)
        }
        view.layoutIfNeeded()
    }
}
