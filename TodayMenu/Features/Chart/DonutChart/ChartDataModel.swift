//
//  DonutChartDataModel.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import Foundation

struct DonutChartDataModel {
    let label: String // 표시용 이름 (예: "한식")
    let percentage: Double  // 0.0 ~ 1.0 (예: 0.1 = 10%)
    let rawValue: String // 원본 값 (예: "korean")

    init(label: String, percentage: Double, rawValue: String) {
        self.label = label
        self.percentage = max(0.0, min(1.0, percentage))  // 0~1 사이로 제한
        self.rawValue = rawValue
    }
}
    
