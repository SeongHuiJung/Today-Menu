//
//  UIButton+Custom.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

class LabelButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    init(title: String, size: CGFloat, textColor: UIColor) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: .semibold)
        self.setTitleColor(textColor, for: .normal)
        self.backgroundColor = .clear
    }
}

class BarButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String, size: CGFloat, textColor: UIColor, backgroundColor: UIColor, cornerRadius: CGFloat = 8) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: .semibold)
        self.setTitleColor(textColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}
