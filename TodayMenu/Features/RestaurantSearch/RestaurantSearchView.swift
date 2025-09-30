//
//  RestaurantSearchView.swift
//  TodayMenu
//
//  Created by Claude on 9/30/25.
//

import UIKit
import SnapKit

final class RestaurantSearchView: BaseView {
    
    let headerView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "point")
        return view
    }()
    
    let backButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let titleLabel = BasicLabel(
        text: "식당 검색",
        alignment: .left,
        size: FontSize.title,
        weight: .bold,
        textColor: UIColor(named: "fontWhite") ?? .white
    )
    
    let searchContainer = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        view.layer.cornerRadius = 22
        return view
    }()
    
    let searchTextField = {
        let textField = UITextField()
        textField.placeholder = "식당 이름을 입력하세요"
        textField.font = .systemFont(ofSize: FontSize.regular)
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    let searchButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "point")
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        return button
    }()
    
    let resultCountLabel = BasicLabel(
        text: "검색 결과 0개",
        alignment: .left,
        size: FontSize.small,
        weight: .regular,
        textColor: .gray
    )
    
    let tableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 85
        return tableView
    }()
    
    override func configureHierarchy() {
        [headerView, searchContainer, resultCountLabel, tableView].forEach {
            addSubview($0)
        }
        
        [backButton, titleLabel].forEach {
            headerView.addSubview($0)
        }
        
        [searchTextField, searchButton].forEach {
            searchContainer.addSubview($0)
        }
    }
    
    override func configureLayout() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(110)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(12)
            $0.centerY.equalTo(backButton)
        }
        
        searchContainer.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        resultCountLabel.snp.makeConstraints {
            $0.top.equalTo(searchContainer.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(resultCountLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        backgroundColor = .white
    }
}
