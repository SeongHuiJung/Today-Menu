//
//  CustomTextView.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

class CustomTextView: UITextView {
    
    private let placeholderLabel = UILabel()
    
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            checkPlaceholder()
        }
    }
    
    var placeholderColor: UIColor = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // TextView 기본 설정
    private func setup() {
        
        text = ""
        delegate = self
        
        placeholderLabel.textColor = .fontLightGray
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = font
        placeholderLabel.backgroundColor = .clear
        
        addSubview(placeholderLabel)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17)
        ])
        
        checkPlaceholder()
    }
    
    private func checkPlaceholder() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    static func reviewStyle(placeholder: String) -> CustomTextView {
        let textView = CustomTextView()
        textView.placeholder = placeholder
        textView.font = .systemFont(ofSize: FontSize.context)
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }
}

extension CustomTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkPlaceholder()
    }
}
