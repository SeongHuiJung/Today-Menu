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
        view.backgroundColor = .pointBackground0
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

    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .center
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let downArrow = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        button.setImage(downArrow, for: .normal)
        button.tintColor = .fontBlack
        button.isHidden = true
        return button
    }()

    private var allCategories: [CategoryCellDataModel] = []
    private var categories: [CategoryCellDataModel] = []
    private let maxVisibleItems = 5
    private var isExpanded = false

    override func configureHierarchy() {
        addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(expandButton)
    }

    override func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(220) // 초기 높이 (5개 * 44)
        }

        expandButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(36)
        }
    }

    override func configureView() {
        backgroundColor = .clear
        expandButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
    }

    func configure(data: [CategoryCellDataModel]) {

        self.allCategories = data

        // 초기 상태에는 최대 5개까지만 표기
        self.isExpanded = false
        self.categories = Array(data.prefix(maxVisibleItems))
        
        // 5개 초과일 때만 더보기 버튼 표시
        expandButton.isHidden = data.count <= maxVisibleItems

        updateLayout()
    }

    private func updateLayout() {
        tableView.reloadData()

        // 테이블 뷰 높이 업데이트
        let height = CGFloat(categories.count) * 44
        tableView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }

    @objc private func toggleExpand() {
        isExpanded.toggle()

        // 확장: 모든 카테고리 표시
        if isExpanded {
            categories = allCategories

            let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
            let upArrow = UIImage(systemName: "chevron.up", withConfiguration: imageConfig)
            expandButton.setImage(upArrow, for: .normal)
        }

        // 축소: 5개만 표시
        else {
            categories = Array(allCategories.prefix(maxVisibleItems))

            let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
            let downArrow = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
            expandButton.setImage(downArrow, for: .normal)
            adjustScrollViewOnCollapse()
        }

        // 새로운 높이 적용
        let newHeight = CGFloat(self.categories.count) * 44
        self.tableView.snp.updateConstraints { make in
            make.height.equalTo(newHeight)
        }
        self.layoutIfNeeded()

        UIView.transition(with: tableView,
                         duration: 0.25,
                         options: [.transitionCrossDissolve],
                         animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }

    // 부드럽게 스크롤 조정
    private func adjustScrollViewOnCollapse() {
        guard let scrollView = self.superview?.superview as? UIScrollView else { return }

        let currentContentHeight = scrollView.contentSize.height
        let heightDifference = CGFloat(allCategories.count - maxVisibleItems) * 44

        let currentOffset = scrollView.contentOffset.y
        let newContentHeight = currentContentHeight - heightDifference
        let maxOffset = max(0, newContentHeight - scrollView.bounds.height + scrollView.contentInset.bottom)

        if currentOffset > maxOffset {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                scrollView.contentOffset = CGPoint(x: 0, y: maxOffset)
            }, completion: nil)
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

        cell.configure(with: categories[indexPath.row], index: indexPath.row)
        return cell
    }
}
