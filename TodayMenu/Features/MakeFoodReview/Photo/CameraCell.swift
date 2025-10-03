//
//  CameraCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/3/25.
//

import UIKit
import SnapKit

final class CameraCell: BaseCollectionViewCell {
    
    private let cameraIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "camera.fill")
        iv.tintColor = .darkGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "카메라"
        label.font = .systemFont(ofSize: 13, weight: .medium)
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
        backgroundColor = UIColor.systemGray6
        
        contentView.addSubview(cameraIconView)
        contentView.addSubview(titleLabel)
        
        cameraIconView.snp.makeConstraints {
            $0.center.equalToSuperview().offset(-10)
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(cameraIconView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
}
