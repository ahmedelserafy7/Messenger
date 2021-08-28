//
//  CustomTabBarController.swift
//  FbMessenger
//
//  Created by Ahmed.S.Elserafy on 6/17/17.
//  Copyright © 2017 Ahmed.S.Elserafy. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout: layout)
        let recentNavMessageController = UINavigationController(rootViewController: friendsController)
        recentNavMessageController.tabBarItem.title = "Recent"
        recentNavMessageController.tabBarItem.image = UIImage(named: "recent")
        
        viewControllers = [recentNavMessageController,createDummyNavControllerWithTitleAndImageName(title: "Calls", imageName: "calls"),createDummyNavControllerWithTitleAndImageName(title: "Groups", imageName: "groups"),createDummyNavControllerWithTitleAndImageName(title: "People", imageName: "people"),createDummyNavControllerWithTitleAndImageName(title: "Settings", imageName: "settings")]
    }
    private func createDummyNavControllerWithTitleAndImageName(title: String,imageName: String)->UINavigationController{
        
        let viewController = UIViewController()
        let viewNavController = UINavigationController(rootViewController:viewController)
        viewNavController.tabBarItem.title = title
        viewNavController.tabBarItem.image = UIImage(named: imageName)
        return viewNavController
    }
    
}
