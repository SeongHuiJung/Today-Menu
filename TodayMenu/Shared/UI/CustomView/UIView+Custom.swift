//
//  UIView+Custom.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

class BasicView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(backgroundColor: UIColor, cornerRadius: CGFloat) {
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}

class CornerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label = BasicLabel(text: "", alignment: .center, size: FontSize.small, textColor: .point2)
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(4)
            make.horizontalEdges.equalToSuperview().inset(5)
        }
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.point2.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
    }
}
