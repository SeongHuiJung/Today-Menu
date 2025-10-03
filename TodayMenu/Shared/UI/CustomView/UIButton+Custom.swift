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

class StarButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    convenience init(tag: Int) {
        self.init(type: .custom)
        self.tag = tag
    }
    
    private func setupButton() {
        titleLabel?.font = .systemFont(ofSize: 32)
        updateAppearance()
    }
    
    private func updateAppearance() {
        if isSelected {
            setTitle("★", for: .normal)
            setTitleColor(UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0), for: .normal)
        } else {
            setTitle("☆", for: .normal)
            setTitleColor(.lightGray, for: .normal)
        }
    }
}

class TagButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    convenience init(title: String) {
        self.init(type: .custom)
        setTitle(title, for: .normal)
    }

    private func setupButton() {
        var config = UIButton.Configuration.filled()
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: FontSize.small, weight: .medium)
            return outgoing
        }
        config.cornerStyle = .fixed
        configuration = config
        
        layer.cornerRadius = 16
        updateAppearance()
    }
    
    private func updateAppearance() {
        var config = configuration
        if isSelected {
            config?.baseBackgroundColor = .point
            config?.baseForegroundColor = .white
        } else {
            config?.baseBackgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.95, alpha: 1.0)
            config?.baseForegroundColor = .point
        }
        configuration = config
    }
}

final class PhotoCaptureButton: UIButton {
    
    private let cameraIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "camera.fill")
        iv.tintColor = .darkGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        
        addSubview(cameraIconView)
        addSubview(countLabel)
        
        cameraIconView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-8)
            $0.width.height.equalTo(32)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(cameraIconView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
    }
    
    func updateCount(current: Int, max: Int) {
        countLabel.text = "\(current)/\(max)"
    }
}
