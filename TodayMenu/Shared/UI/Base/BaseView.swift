//
//  BaseView.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        configureView()
    }

    func configureHierarchy() {}
    
    func configureLayout() {}
    
    func configureView() {
        self.backgroundColor = .customBackground
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
