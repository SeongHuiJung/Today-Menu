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
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
    }
    
    func configure(date: Int, isWeekend: Bool) {
        dateLabel.text = "\(date)"
        dateLabel.textColor = isWeekend ? .systemRed : .black
    }
}
