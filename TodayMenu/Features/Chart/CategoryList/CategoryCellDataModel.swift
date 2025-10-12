//
//  CategoryCellDataModel.swift
//  TodayMenu
//
//  Created by 정성희 on 10/12/25.
//

import Foundation

struct CategoryCellDataModel {
    let name: String // 음식 이름 (category)
    let percentage: Double // 해당 cuisine 내에서의 비율
    let count: Int // 먹은 횟수

    init(name: String, percentage: Double, count: Int) {
        self.name = name
        self.percentage = percentage
        self.count = count
    }
}
