//
//  RestaurantSearchView.swift
//  TodayMenu
//
//  Created by 정성희 on 9/30/25.
//

import UIKit
import SnapKit

final class RestaurantSearchView: BaseView {
    
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
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .customGray3
        button.backgroundColor = .clear
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
        [searchContainer, resultCountLabel, tableView].forEach {
            addSubview($0)
        }

        [searchTextField, searchButton].forEach {
            searchContainer.addSubview($0)
        }
    }
    
    override func configureLayout() {

        searchContainer.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
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
