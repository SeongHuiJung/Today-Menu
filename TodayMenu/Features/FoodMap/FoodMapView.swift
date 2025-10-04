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
        map.mapType = .mutedStandard
        
        map.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            .restaurant,
            .cafe,
            .bakery,
            .brewery,
            .winery
        ])
        
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
    
    let floatingView = RestaurantDetailFloatingView()
    
    override func configureHierarchy() {
        addSubview(mapView)
        addSubview(locationButton)
        addSubview(floatingView)
        
        floatingView.isHidden = true
    }
    
    override func configureLayout() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()  // safeArea 무시하고 전체 화면에 표시
        }
        
        locationButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.width.height.equalTo(56)
        }
        
        floatingView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).offset(250) // 초기에는 화면 밖에
            make.height.equalTo(250)
        }
    }
    
    override func configureView() {
        backgroundColor = .white
    }
    
    func showFloatingView(restaurantName: String, lastVisit: Date, averageRating: Double, cuisine: String) {
        floatingView.configure(restaurantName: restaurantName, lastVisit: lastVisit, averageRating: averageRating, cuisine: cuisine)
        floatingView.isHidden = false
        
        floatingView.snp.updateConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(0)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        }
    }
    
    func updateFloatingView(lastVisit: Date, averageRating: Double) {
        floatingView.updateData(lastVisit: lastVisit, averageRating: averageRating)
    }
    
    func hideFloatingView() {
        floatingView.snp.updateConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(250)
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        }) { _ in
            self.floatingView.isHidden = true
        }
    }
}
