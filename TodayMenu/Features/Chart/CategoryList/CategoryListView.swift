//
//  CategoryListView.swift
//  TodayMenu
//
//  Created by 정성희 on 10/12/25.
//

import UIKit
import SnapKit

final class CategoryListView: BaseView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.rowHeight = 44
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.dataSource = self
        return table
    }()

    private var categories: [CategoryCellDataModel] = []
    private let maxVisibleItems = 5

    override func configureHierarchy() {
        addSubview(containerView)
        containerView.addSubview(tableView)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    override func configureView() {
        backgroundColor = .clear
    }

    func configure(with data: [CategoryCellDataModel]) {
        // 최대 5개까지만 표시
        self.categories = Array(data.prefix(maxVisibleItems))
        tableView.reloadData()

        // 테이블 뷰 높이 업데이트
        let height = CGFloat(categories.count) * 44
        tableView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(height)
        }
    }
}

// MARK: - UITableViewDataSource
extension CategoryListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }

        cell.configure(with: categories[indexPath.row])
        return cell
    }
}
