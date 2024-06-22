//
//  ModulesFactory.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import UIKit

final class ModulesFactory {
    static func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let firstVC = createSearchViewController()
        let secondVC = createFavoritesViewController()
        
        tabBarController.viewControllers = [firstVC, secondVC]
        
        return tabBarController
    }
    
    static func createSearchViewController() -> UIViewController {
        let searchVC = SearchViewController()
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        return searchVC
    }
    
    static func createFavoritesViewController() -> UIViewController {
        let secondVC = FavoritesViewController()
        secondVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        return secondVC
    }
}
