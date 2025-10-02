//
//  CalendarEmptyCell.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import UIKit
import FSCalendar
import SnapKit

final class CalendarEmptyCell: FSCalendarCell {
    
    private let dateLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let backgroundColorView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.08
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [backgroundColorView, dateLabel].forEach {
            contentView.addSubview($0)
        }
        
        backgroundColorView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
    }
    
    func configure(date: Int, isWeekend: Bool, isFuture: Bool = false) {
        dateLabel.text = "\(date)"
        
        if isFuture {
            // 미래 날짜는 회색 처리
            dateLabel.textColor = .lightGray
            backgroundColorView.backgroundColor = UIColor.systemGray6
        } else {
            dateLabel.textColor = isWeekend ? .systemRed : .black
            backgroundColorView.backgroundColor = .white
        }
    }
}
