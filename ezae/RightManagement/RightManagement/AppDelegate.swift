//
//  AppDelegate.swift
//  RightManagement
//
//  Created by Munish Sethi on 09/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // iOS 10 support
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        ReachabilityManager.shared.startMonitoring()
        if #available(iOS 10.0, *) {
            UIApplication.shared.registerForRemoteNotifications()
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self //DID NOT WORK WHEN self WAS MyOtherDelegateClass()
            
            center.requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                    // update application settings
                }
            }

        } else {
            // Fallback on earlier versions
        }
        return true
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        if UIApplication.shared.applicationState == .active {
            let currentController = UIApplication.topViewController()
            if(currentController is MessageChatController){
                let userInfo = notification.request.content.userInfo as? NSDictionary
                let notificationData = userInfo!["data"] as! [String:Any]
                let entitySeq = notificationData["entitySeq"] as! String
                let entityType = notificationData["entityType"] as! String
                let mcv = currentController as! MessageChatController
                let chatUserSeq = mcv.chatUserSeq;
                let chatUserType = mcv.charUserType;
                if(chatUserSeq == Int(entitySeq) && chatUserType == entityType){
                    mcv.getMessages(isScroll: false);
                }else{
                    withCompletionHandler([.alert, .sound, .badge])
                }
                return;
            }
        }
        withCompletionHandler([.alert, .sound, .badge])
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        PreferencesUtil.sharedInstance.setDeviceId(deviceId: deviceTokenString)
        // Persist it in your backend in case it's new
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    
 
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let state = UIApplication.shared.applicationState
        print("Push notification received: \(userInfo)")
        let notificationData = userInfo["data"] as! [String:Any]
        let entitySeq = notificationData["entitySeq"] as! String
        let entityType = notificationData["entityType"] as! String
        var fromUserName = notificationData["fromUserName"] as? String
        var lpSeq = notificationData["lpSeq"] as? String
        if(lpSeq == nil){
            lpSeq = "0"
        }
        if(fromUserName == nil){
            fromUserName = ""
        }
        let prefUtil = PreferencesUtil.sharedInstance
        prefUtil.setNotificationState(flag: true)
        prefUtil.setNotificationData(entityType: entityType, entitySeq: entitySeq,fromUserName:fromUserName!,lpSeq:lpSeq!)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var viewController:UIViewController!;
        if(prefUtil.getLoggedInUserSeq() > 0){
             viewController = storyBoard.instantiateViewController(withIdentifier: "MainTab") as UIViewController
        }else{
             viewController = storyBoard.instantiateViewController(withIdentifier: "Login") as UIViewController
        }
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

