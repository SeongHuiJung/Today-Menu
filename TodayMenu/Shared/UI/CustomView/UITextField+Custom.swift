//
//  CustomTextField.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

class BasicTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    init(text: String = "", placeholder: String, size: CGFloat = FontSize.regular, weight: UIFont.Weight = .regular, alignment: NSTextAlignment = .left, textColor: UIColor = .black, backgroundColor: UIColor = .white, canEdit: Bool = true) {
        super.init(frame: .zero)
        
        self.text = text
        self.placeholder = placeholder
        self.font = .systemFont(ofSize: size, weight: weight)
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.textAlignment = alignment
        self.borderStyle = .none

        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        self.leftViewMode = .always
        
        self.isUserInteractionEnabled = canEdit
    }
    
    static func reviewStyle(placeholder: String) -> BasicTextField {
        return BasicTextField(
            placeholder: placeholder,
            size: FontSize.regular,
            backgroundColor: .white
        )
    }
}
