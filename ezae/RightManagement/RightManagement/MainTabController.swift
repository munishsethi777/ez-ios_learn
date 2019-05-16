//
//  MainTabController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 23/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class MainTabController: UITabBarController{
    var isTraining:Bool = false
    override func viewDidLoad() {
       super.viewDidLoad()
       if(isTraining){
         self.selectedIndex = 1
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = UIColor.white
        } else {
            // Fallback on earlier versions
        }
    }
}
