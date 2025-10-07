//
//  CategorySelectionViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 10/7/25.
//

import UIKit
import SnapKit

final class CategorySelectionViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    override func configureView() {
        super.configureView()
        title = "음식 분류 설정"
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.fontBlack]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .fontBlack
    }
}
