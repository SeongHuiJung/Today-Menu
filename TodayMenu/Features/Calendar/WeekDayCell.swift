//
//  WeekDayCell.swift
//  TodayMenu
//
//  Created by Claude on 10/1/25.
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
    
    private func setupUI() {
        contentView.addSubview(containerView)
        [dayLabel, dateLabel].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func configure(date: Date, isWeekend: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "E"
        dayLabel.text = dateFormatter.string(from: date)
        
        let day = Calendar.current.component(.day, from: date)
        dateLabel.text = "\(day)"
        
        if isWeekend && !isSelected {
            dayLabel.textColor = .systemRed
            dateLabel.textColor = .systemRed
        }
    }
    
    private func updateSelection() {
        if isSelected {
            containerView.backgroundColor = UIColor(named: "point")
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            containerView.backgroundColor = .white
            dayLabel.textColor = .darkGray
            dateLabel.textColor = .black
        }
    }
}
