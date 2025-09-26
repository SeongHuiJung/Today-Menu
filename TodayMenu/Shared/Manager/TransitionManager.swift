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
        tabBarAppearance.backgroundColor = .customBackground
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .customGray
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        let page1 = UINavigationController(rootViewController: FoodRecommendViewController())
        let page2 = UINavigationController(rootViewController: FoodMapViewController())

        page1.view.backgroundColor = .customBackground
        page2.view.backgroundColor = .customBackground
        
        tabBarController.setViewControllers([page1, page2], animated: true)
        
        if let items = tabBarController.tabBar.items {
            items[0].selectedImage = UIImage(systemName: SFsymbol.starBubbleFill.rawValue)
            items[0].image = UIImage(systemName: SFsymbol.starBubbleFill.rawValue)
            
            items[1].selectedImage = UIImage(systemName: SFsymbol.mapFill.rawValue)
            items[1].image = UIImage(systemName: SFsymbol.mapFill.rawValue)
        }
        
        return tabBarController
    }
}
