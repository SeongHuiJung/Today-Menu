//
//  PhotoCell.swift
//  TodayMenu
//
//  Created by 정성희 on 10/3/25.
//

import UIKit
import Photos
import SnapKit

final class PhotoCell: BaseCollectionViewCell {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let selectionOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()
    
    private let selectionBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let unselectedCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private var requestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let requestID = requestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        
        imageView.image = nil
        selectionOverlay.isHidden = true
        selectionBadge.isHidden = true
        unselectedCircle.isHidden = false
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectionOverlay)
        contentView.addSubview(unselectedCircle)
        contentView.addSubview(selectionBadge)
        selectionBadge.addSubview(selectionLabel)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        selectionOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        unselectedCircle.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(6)
            $0.width.height.equalTo(24)
        }
        
        selectionBadge.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(6)
            $0.width.height.equalTo(24)
        }
        
        selectionLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with asset: PHAsset) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        let targetSize = CGSize(
            width: contentView.bounds.width * UIScreen.main.scale,
            height: contentView.bounds.height * UIScreen.main.scale
        )
        
        requestID = imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            self?.imageView.image = image
        }
    }
    
    func updateSelection(isSelected: Bool, index: Int?) {
        selectionOverlay.isHidden = !isSelected
        selectionBadge.isHidden = !isSelected
        unselectedCircle.isHidden = isSelected
        
        if let index = index {
            selectionLabel.text = "\(index + 1)"
        }
    }
}
