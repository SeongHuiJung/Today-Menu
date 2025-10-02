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
import RxCocoa

final class CalendarViewController: BaseViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel: CalendarViewModel
    
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let dateSelectedSubject = PublishSubject<Date>()
    private let weekDateSelectedSubject = PublishSubject<Date>()
    private let reviewSelectedSubject = PublishSubject<Review>()
    private let calendarBackTappedSubject = PublishSubject<Void>()
    
    private var reviewsByDate: [String: [Review]] = [:]
    private var currentReviews: [Review] = []
    private var weekDates: [Date] = []
    private var isCalendarHidden = false
    
    // MARK: - UI Components
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
    
    private let weekContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        return view
    }()
    
    private let dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .center
        return stackView
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var weekScrollView: UICollectionView = {
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
    
    private let reviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .backgroundGray
        tableView.separatorStyle = .none
        tableView.alpha = 0
        return tableView
    }()
    
    // MARK: - Init
    init(viewModel: CalendarViewModel = CalendarViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        setupWeekScrollView()
        setupReviewTableView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    // MARK: - Configuration
    override func configureHierarchy() {
        super.configureHierarchy()
        
        view.addSubview(calendarContainerView)
        calendarContainerView.addSubview(calendar)
        view.addSubview(weekContainerView)
        weekContainerView.addSubview(dateStackView)
        weekContainerView.addSubview(weekScrollView)
        view.addSubview(reviewTableView)
        
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
        
        weekScrollView.snp.makeConstraints {
            $0.leading.equalTo(dateStackView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        reviewTableView.snp.makeConstraints {
            $0.top.equalTo(weekContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        super.configureView()
        view.backgroundColor = .backgroundGray
        title = "음식 History"
    }
}

// MARK: - Setup
private extension CalendarViewController {
    
    func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.register(CalendarReviewCell.self, forCellReuseIdentifier: "reviewCell")
        calendar.register(CalendarEmptyCell.self, forCellReuseIdentifier: "emptyCell")
    }
    
    func setupWeekScrollView() {
        weekScrollView.dataSource = self
        weekScrollView.delegate = self
        weekScrollView.register(WeekDayCell.self, forCellWithReuseIdentifier: WeekDayCell.identifier)
    }
    
    func setupReviewTableView() {
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        reviewTableView.register(CalendarReviewListCell.self, forCellReuseIdentifier: CalendarReviewListCell.identifier)
    }
}

// MARK: - Binding
private extension CalendarViewController {
    
    func bindViewModel() {
        let input = CalendarViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            dateSelected: dateSelectedSubject.asObservable(),
            weekDateSelected: weekDateSelectedSubject.asObservable(),
            reviewSelected: reviewSelectedSubject.asObservable(),
            calendarBackTapped: calendarBackTappedSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 리뷰 데이터 바인딩
        output.reviewsByDate
            .drive(onNext: { [weak self] reviewsByDate in
                self?.reviewsByDate = reviewsByDate
                self?.calendar.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 현재 리뷰 리스트 바인딩
        output.currentReviews
            .drive(onNext: { [weak self] reviews in
                self?.currentReviews = reviews
                self?.reviewTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 주간 날짜 바인딩
        output.weekDates
            .drive(onNext: { [weak self] dates in
                self?.weekDates = dates
                self?.weekScrollView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 캘린더 숨김
        output.shouldHideCalendar
            .drive(onNext: { [weak self] date in
                self?.hideCalendar(selectedDate: date)
            })
            .disposed(by: disposeBag)
        
        // 캘린더 보이기
        output.shouldShowCalendar
            .drive(onNext: { [weak self] in
                self?.showCalendar()
            })
            .disposed(by: disposeBag)
        
        // 날짜 라벨 업데이트
        output.dateLabels
            .drive(onNext: { [weak self] labels in
                self?.yearLabel.text = labels.year
                self?.monthLabel.text = labels.month
            })
            .disposed(by: disposeBag)
        
        // 리뷰 상세보기
        output.reviewDetailTrigger
            .drive(onNext: { [weak self] review in
                self?.navigateToReviewDetail(review)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Helper Methods
private extension CalendarViewController {
    
    func getReviews(for date: Date) -> [Review] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: date)
        return reviewsByDate[dateKey] ?? []
    }
    
    func hideCalendar(selectedDate: Date) {
        guard !isCalendarHidden else { return }
        isCalendarHidden = true
        
        calendarContainerView.snp.remakeConstraints {
            $0.bottom.equalTo(view.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(calendarContainerView.frame.height)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.weekContainerView.alpha = 1
            self.reviewTableView.alpha = 1
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.weekScrollView.reloadData()
            
            if let selectedIndex = self.weekDates.firstIndex(where: {
                Calendar.current.isDate($0, inSameDayAs: selectedDate)
            }) {
                let indexPath = IndexPath(item: selectedIndex, section: 0)
                self.weekScrollView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    func showCalendar() {
        guard isCalendarHidden else { return }
        isCalendarHidden = false
        
        calendarContainerView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.weekContainerView.alpha = 0
            self.reviewTableView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func navigateToReviewDetail(_ review: Review) {
        print("선택된 리뷰: \(review.food.first?.name ?? "")")
        // TODO: 리뷰 상세 화면으로 이동
    }
}

// MARK: - FSCalendarDataSource
extension CalendarViewController: FSCalendarDataSource {
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        // 최대 날짜는 오늘
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let today = Date()
        let endOfToday = cal.date(bySettingHour: 23, minute: 59, second: 59, of: today) ?? today
        return endOfToday
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let reviews = getReviews(for: date)
        
        // 미래 날짜 체크
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let today = cal.startOfDay(for: Date())
        let cellDate = cal.startOfDay(for: date)
        let isFuture = cellDate > today
        
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
            
            cell.configure(date: day, isWeekend: isWeekend, isFuture: isFuture)
            
            return cell
        }
    }
}

// MARK: - FSCalendarDelegate
extension CalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateSelectedSubject.onNext(date)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints {
            $0.height.equalTo(bounds.height)
        }
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        // 미래 날짜 선택 불가
        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let today = cal.startOfDay(for: Date())
        let selectedDate = cal.startOfDay(for: date)
        return selectedDate <= today
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
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let cellDate = calendar.startOfDay(for: date)
        let isFuture = cellDate > today
        
        cell.configure(date: date, isWeekend: isWeekend, isFuture: isFuture)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CalendarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let date = weekDates[indexPath.item]
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let cellDate = calendar.startOfDay(for: date)
        
        return cellDate <= today
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = weekDates[indexPath.item]
        weekDateSelectedSubject.onNext(date)
    }
}

// MARK: - UITableViewDataSource
extension CalendarViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CalendarReviewListCell.identifier, for: indexPath) as! CalendarReviewListCell
        
        let review = currentReviews[indexPath.row]
        cell.configure(review: review)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CalendarViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectItemAt indexPath: IndexPath) {
        let review = currentReviews[indexPath.row]
        reviewSelectedSubject.onNext(review)
    }
}
