//
//  CategorySelectionView.swift
//  TodayMenu
//
//  Created by 정성희 on 10/7/25.
//

import UIKit
import SnapKit

final class CategorySelectionView: BaseView {

    // 대분류 테이블뷰
    let cuisineTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CuisineTableViewCell.self, forCellReuseIdentifier: CuisineTableViewCell.identifier)
        return tableView
    }()

    // 중분류 컬렉션뷰
    lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = true
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        return collectionView
    }()

    override func configureHierarchy() {
        [cuisineTableView, categoryCollectionView].forEach {
            addSubview($0)
        }
    }

    override func configureLayout() {
        cuisineTableView.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(safeAreaLayoutGuide)
            $0.width.equalTo(120)
        }

        categoryCollectionView.snp.makeConstraints {
            $0.top.trailing.bottom.equalTo(safeAreaLayoutGuide)
            $0.leading.equalTo(cuisineTableView.snp.trailing)
        }
    }

    override func configureView() {
        backgroundColor = .white
    }
}
