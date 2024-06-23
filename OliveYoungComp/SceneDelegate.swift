//
//  SceneDelegate.swift
//  OliveYoungComp
//
//  Created by 김태현 on 5/12/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = UITabBarController()
        
        let categoryURL = URL(string: "https://m.oliveyoung.co.kr/m/menu/drawer?t_page=%ED%99%88&t_click=%ED%83%AD%EB%B0%94")
        let shutterURL = URL(string: "https://m.oliveyoung.co.kr/m/mtn/shutter?t_page=%EC%85%94%ED%84%B0&t_click=%ED%99%88_%ED%83%AD%EB%B0%94_%EC%85%94%ED%84%B0")
        let homeURL = URL(string: "https://m.oliveyoung.co.kr/m/mtn")
        let historyURL = URL(string: "https://m.oliveyoung.co.kr/m/mtn/history")
        let profileURL = URL(string: "https://m.oliveyoung.co.kr/m/mypage/myPageMain.do")
        
        let categoryViewController = GenericViewController(url: categoryURL)
        let shutterViewController = GenericViewController(url: shutterURL)
        let homeViewController = GenericViewController(url: homeURL)
        let historyViewController = GenericViewController(url: historyURL)
        let profileViewController = GenericViewController(url: profileURL)
        
        let categoryNavController = UINavigationController(rootViewController: categoryViewController)
        let shutterNavController = UINavigationController(rootViewController: shutterViewController)
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        let historyNavController = UINavigationController(rootViewController: historyViewController)
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        
        categoryNavController.tabBarItem = UITabBarItem(title: "Category", image: nil, selectedImage: nil)
        shutterNavController.tabBarItem = UITabBarItem(title: "Shutter", image: nil, selectedImage: nil)
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: nil, selectedImage: nil)
        historyNavController.tabBarItem = UITabBarItem(title: "History", image: nil, selectedImage: nil)
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
        
        tabBarController.viewControllers = [categoryNavController, shutterNavController, homeNavController, historyNavController, profileNavController]
        tabBarController.selectedViewController = homeNavController
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
