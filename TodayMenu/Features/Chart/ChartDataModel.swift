//
//  ChartDataModel.swift
//  TodayMenu
//
//  Created by 정성희 on 10/11/25.
//

import Foundation

struct ChartDataModel {
    let label: String
    let percentage: Double  // 0.0 ~ 1.0 (예: 0.1 = 10%)

    init(label: String, percentage: Double) {
        self.label = label
        self.percentage = max(0.0, min(1.0, percentage))  // 0~1 사이로 제한
    }
}
    