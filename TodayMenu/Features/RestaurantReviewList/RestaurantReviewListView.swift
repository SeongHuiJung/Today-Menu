//
//  RestaurantReviewListView.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import UIKit
import SnapKit

final class RestaurantReviewListView: BaseView {
    
    let tableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let emptyStateLabel = {
        let label = UILabel()
        label.text = "작성된 리뷰가 없어요."
        label.font = .systemFont(ofSize: FontSize.regular, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(emptyStateLabel)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        emptyStateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func configureView() {
        backgroundColor = .white
    }
    
    func showEmptyState(_ show: Bool) {
        emptyStateLabel.isHidden = !show
        tableView.isHidden = show
    }
}
