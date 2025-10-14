//
//  dd.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

final class PaddingLabel: UILabel {
    private let insets: UIEdgeInsets
    
    override init(frame: CGRect) {
        self.insets = .zero
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    init(insets: UIEdgeInsets, text: String, alignment: NSTextAlignment, size: CGFloat, backgroundColor: UIColor, textColor: UIColor = .black, weight: UIFont.Weight = .regular, cornerRadius: CGFloat = 14) {
        self.insets = insets
        super.init(frame: .zero)
        
        self.text = text
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.textAlignment = alignment
        self.font = .systemFont(ofSize: size, weight: weight)
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }

    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        return CGSize(width: intrinsicContentSize.width + insets.left + insets.right,
                      height: intrinsicContentSize.height + insets.top + insets.bottom)
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}

class BasicLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    init(text: String, alignment: NSTextAlignment, size: CGFloat, weight: UIFont.Weight = .regular, textColor: UIColor = .black, numberOfLines: Int = 0) {
        super.init(frame: .zero)
        
        self.text = text
        self.textColor = textColor
        self.textAlignment = alignment
        self.font = .systemFont(ofSize: size, weight: weight)
        self.numberOfLines = numberOfLines
    }
}
