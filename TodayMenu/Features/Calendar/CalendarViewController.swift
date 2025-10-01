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
    
    private let weekContainerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        return view
    }()
    
    private let dateStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .center
        return stackView
    }()
    
    private let yearLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let monthLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let weekColleciontView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 60, height: 80)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var reviewsByDate: [String: [Review]] = [:]
    private var isCalendarHidden = false
    private var selectedDate: Date?
    private var weekDates: [Date] = []
    private var oldestReviewDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        setupCollectionView()
        loadReviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReviews()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        [calendarContainerView, weekContainerView].forEach { view.addSubview($0) }
        [calendar].forEach { calendarContainerView.addSubview($0) }
        [dateStackView, weekColleciontView].forEach { weekContainerView.addSubview($0) }
        
        [yearLabel, monthLabel].forEach {
            dateStackView.addArrangedSubview($0)
        }
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
        
        weekContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        dateStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
        }
        
        weekColleciontView.snp.makeConstraints {
            $0.leading.equalTo(dateStackView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
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
    
    private func setupCollectionView() {
        weekColleciontView.dataSource = self
        weekColleciontView.delegate = self
        weekColleciontView.register(WeekDayCell.self, forCellWithReuseIdentifier: WeekDayCell.identifier)
    }
    
    private func loadReviews() {
        repository.fetchAllReviews()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] reviews in
                self?.organizeReviewsByDate(reviews)
                self?.calendar.reloadData()
                
                if let oldest = reviews.map({ $0.ateAt }).min() {
                    self?.oldestReviewDate = oldest
                }
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
    
    private func generateWeekDates(around date: Date) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        let today = Date()
        let twoDaysLater = calendar.date(byAdding: .day, value: 2, to: today) ?? today
        let startDate = oldestReviewDate ?? calendar.date(byAdding: .month, value: -3, to: today) ?? today
        
        var currentDate = startDate
        while currentDate <= twoDaysLater {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
    
    private func updateDateLabels() {
        let visibleRect = CGRect(origin: weekColleciontView.contentOffset, size: weekColleciontView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let indexPath = weekColleciontView.indexPathForItem(at: visiblePoint),
           indexPath.item < weekDates.count {
            let visibleDate = weekDates[indexPath.item]
            let month = Calendar.current.component(.month, from: visibleDate)
            let year = Calendar.current.component(.year, from: visibleDate)
            
            yearLabel.text = "\(year)년"
            monthLabel.text = "\(month)월"
        }
    }
    
    private func hideCalendar(selectedDate: Date) {
        guard !isCalendarHidden else { return }
        isCalendarHidden = true
        self.selectedDate = selectedDate
        self.weekDates = generateWeekDates(around: selectedDate)
        
        let month = Calendar.current.component(.month, from: selectedDate)
        let year = Calendar.current.component(.year, from: selectedDate)
        yearLabel.text = "\(year)년"
        monthLabel.text = "\(month)월"
        
        calendarContainerView.snp.remakeConstraints {
            $0.bottom.equalTo(view.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(calendarContainerView.frame.height)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.weekContainerView.alpha = 1
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.weekColleciontView.reloadData()
            
            if let selectedIndex = self.weekDates.firstIndex(where: {
                Calendar.current.isDate($0, inSameDayAs: selectedDate)
            }) {
                let indexPath = IndexPath(item: selectedIndex, section: 0)
                self.weekColleciontView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
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
            self.weekContainerView.alpha = 0
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
            hideCalendar(selectedDate: date)
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints {
            $0.height.equalTo(bounds.height)
        }
        view.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weekDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekDayCell.identifier, for: indexPath) as! WeekDayCell
        
        let date = weekDates[indexPath.item]
        let weekday = Calendar.current.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        
        let today = Date()
        let isFuture = date > today
        
        cell.configure(date: date, isWeekend: isWeekend, isFuture: isFuture)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CalendarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let date = weekDates[indexPath.item]
        let today = Date()
        return date <= today
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = weekDates[indexPath.item]
        selectedDate = date
        print("주간 뷰에서 선택된 날짜: \(date)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateDateLabels()
    }
}
