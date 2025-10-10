//
//  TransitionManager.swift
//  TodayMenu
//
//  Created by 정성희 on 9/25/25.
//

import UIKit

class TransitionManager {
    static let shared = TransitionManager()
    private init() {}
    
    func getMainTabViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .customWhite
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .point2
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .customGray3
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.customGray3]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.point2]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        let page1 = UINavigationController(rootViewController: FoodRecommendViewController())
        let page2 = UINavigationController(rootViewController: FoodMapViewController())
        let page3 = UINavigationController(rootViewController: CalendarViewController())
        let page4 = UINavigationController(rootViewController: ChartViewController())

        page1.view.backgroundColor = .customWhite
        page2.view.backgroundColor = .customWhite
        page3.view.backgroundColor = .customWhite
        page4.view.backgroundColor = .customWhite
        
        tabBarController.setViewControllers([page1, page2, page3, page4], animated: true)
        
        if let items = tabBarController.tabBar.items {
            items[0].selectedImage = UIImage(systemName: SFsymbol.starBubbleFill.rawValue)
            items[0].image = UIImage(systemName: SFsymbol.starBubbleFill.rawValue)
            items[0].title = "추천"
            
            items[1].selectedImage = UIImage(systemName: SFsymbol.mapFill.rawValue)
            items[1].image = UIImage(systemName: SFsymbol.mapFill.rawValue)
            items[1].title = "지도"
            
            items[2].selectedImage = UIImage(systemName: SFsymbol.calendar.rawValue)
            items[2].image = UIImage(systemName: SFsymbol.calendar.rawValue)
            items[2].title = "달력"
            
            items[3].selectedImage = UIImage(systemName: SFsymbol.chartBarFill.rawValue)
            items[3].image = UIImage(systemName: SFsymbol.chartBarFill.rawValue)
            items[3].title = "통계"
        }
        
        return tabBarController
    }
}
