//
//  FoodMapView.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import UIKit
import MapKit
import SnapKit

final class FoodMapView: BaseView {
    
    let mapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.showsCompass = true
        map.showsScale = true
        return map
    }()
    
    let locationButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .point
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "location.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(mapView)
        addSubview(locationButton)
    }
    
    override func configureLayout() {
        mapView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        locationButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.width.height.equalTo(56)
        }
    }
    
    override func configureView() {
        backgroundColor = .white
    }
}
