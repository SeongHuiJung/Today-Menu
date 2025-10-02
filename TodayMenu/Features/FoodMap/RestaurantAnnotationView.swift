//
//  RestaurantAnnotationView.swift
//  TodayMenu
//
//  Created by 정성희 on 10/2/25.
//

import UIKit
import MapKit
import SnapKit

final class RestaurantAnnotationView: MKAnnotationView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "annotation-food")
        return imageView
    }()
    
    private let nameLabel: StrokedLabel = {
        let label = StrokedLabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.alpha = 0
        label.strokeColor = .white
        label.strokeWidth = 3.0
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        canShowCallout = false
        
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        frame.size = CGSize(width: 100, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    }
    
    func configure(with annotation: RestaurantAnnotation) {
        guard let title = annotation.title else { return }
        
        nameLabel.text = title
        
        let textWidth = title.size(
            withAttributes: [.font: nameLabel.font!]
        ).width
        
        let labelWidth = min(textWidth + 12, 100)
        
        nameLabel.snp.remakeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(18)
            $0.width.greaterThanOrEqualTo(labelWidth)
        }
    }
    
    func updateLabelVisibility(zoomLevel: Double) {
        // 줌 레벨이 15 이상일 때만 라벨 표시 (약 500m 반경)
        let shouldShow = zoomLevel >= 15
        
        UIView.animate(withDuration: 0.2) {
            self.nameLabel.alpha = shouldShow ? 1 : 0
        }
    }
}

final class StrokedLabel: UILabel {
    
    var strokeColor: UIColor = .white
    var strokeWidth: CGFloat = 3.0
    
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let textColor = self.textColor
        
        context?.setLineWidth(strokeWidth)
        context?.setLineJoin(.round)
        context?.setTextDrawingMode(.stroke)
        self.textColor = strokeColor
        super.drawText(in: rect)
        
        context?.setTextDrawingMode(.fill)
        self.textColor = textColor
        super.drawText(in: rect)
    }
}
