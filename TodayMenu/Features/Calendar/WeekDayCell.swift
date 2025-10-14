//
//  WeekDayCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/1/25.
//

import UIKit
import SnapKit

final class WeekDayCell: UICollectionViewCell {
    
    private let dayLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let monthLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private var isWeekendDay = false
    private var isFutureDay = false
    
    override var isSelected: Bool {
        didSet {
            updateSelection()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dayLabel.textColor = .darkGray
        dateLabel.textColor = .black
        monthLabel.textColor = .systemGray
        monthLabel.alpha = 0
        monthLabel.text = nil
        containerView.backgroundColor = .white
        isWeekendDay = false
        isFutureDay = false
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        [dayLabel, monthLabel, dateLabel].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }
        
        monthLabel.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(12)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func configure(date: Date, isWeekend: Bool, isFuture: Bool) {
        self.isWeekendDay = isWeekend
        self.isFutureDay = isFuture
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "E"
        dayLabel.text = dateFormatter.string(from: date)
        
        let day = Calendar.current.component(.day, from: date)
        dateLabel.text = "\(day)"
        
        let month = Calendar.current.component(.month, from: date)
        if day == 1 {
            monthLabel.text = "\(month)월"
            monthLabel.alpha = 1
        } else {
            monthLabel.text = ""
            monthLabel.alpha = 0
        }
        
        updateSelection()
    }
    
    private func updateSelection() {
        if isSelected {
            containerView.backgroundColor = .mainPoint
            dayLabel.textColor = .white
            dateLabel.textColor = .white
            monthLabel.textColor = .white
        } else {
            containerView.backgroundColor = .white
            
            if isFutureDay {
                dayLabel.textColor = .systemGray3
                dateLabel.textColor = .systemGray3
                monthLabel.textColor = .systemGray4
            } else if isWeekendDay {
                dayLabel.textColor = .systemRed
                dateLabel.textColor = .systemRed
                monthLabel.textColor = .systemRed
            } else {
                dayLabel.textColor = .darkGray
                dateLabel.textColor = .black
                monthLabel.textColor = .systemGray
            }
        }
    }
}
