//
//  CalendarViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import UIKit
import FSCalendar
import SnapKit

class CalendarViewController: BaseViewController {
    
    private let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.backgroundColor = .white
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.todayColor = .point
        calendar.appearance.selectionColor = .point
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleWeekendColor = .systemRed
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        return calendar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func configureView() {
        super.configureView()
        view.backgroundColor = .white
        title = "캘린더"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.addSubview(calendar)
        
        calendar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(300)
        }
    }
}
