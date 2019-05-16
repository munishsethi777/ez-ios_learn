//
//  TrainingTabController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 21/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
class TrainingTabController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
        let isNotificationState = PreferencesUtil.sharedInstance.isNotificationState()
        if(isNotificationState){
            let data = PreferencesUtil.sharedInstance.getNotificationData()
            let launchModuleSeq = Int(data["entitySeq"]!)!
            let moduleViewController = self.viewControllers![1] as! ModuleViewController
            moduleViewController.isLaunch = true
            moduleViewController.selectedModuleSeq = launchModuleSeq
            PreferencesUtil.sharedInstance.resetNotificationData()
            self.selectedIndex = 1
        }
        // Do any additional setup if required.
    }

    
    @objc func backAction(){
        //print("Back Button Clicked")
        //self.performSegue(withIdentifier: "showDashboard", sender: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
