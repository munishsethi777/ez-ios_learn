//
//  DashboardViewController.swift
//  RightManagement
//
//  Created by Munish Sethi on 22/01/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
import SSCalendar
class DashboardViewController:UIViewController{
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var trainingsView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var achievementsView: UIView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var eventsView: UIView!
    @IBOutlet weak var chatroomsView: UIView!
    @IBOutlet weak var updateProfileView: UIView!
    @IBOutlet weak var changePasswordView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    @IBOutlet weak var messagesCount: UILabel!
    @IBOutlet weak var pendingLpCount: UILabel!
    @IBOutlet weak var notificationsCount: UILabel!
    
    @IBAction func trainingsButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    @IBOutlet weak var points: UILabel!
    
    @IBOutlet weak var companyLogo: UIImageView!
    
    @IBOutlet weak var vendorLogo: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var userProfileLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBAction func messagesButtonAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func chatroomsAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
   
    
//    @IBAction func notificationAction(_ sender: Any) {
//        let controller = self.tabBarController?.viewControllers![4]
//        let settingController = controller?.childViewControllers[0] as! SettingsTableViewController
//        settingController.isGoToNotification = true
//        self.tabBarController?.selectedIndex = 4
//    }
//    @IBAction func achievementAction(_ sender: Any) {
//        let controller = self.tabBarController?.viewControllers![4]
//        let settingController = controller?.childViewControllers[0] as! SettingsTableViewController
//        settingController.isGotoAchivement = true
//        self.tabBarController?.selectedIndex = 4
//    }
    
//    @IBAction func notesAction(_ sender: Any) {
//        let controller = self.tabBarController?.viewControllers![4]
//        let settingController = controller?.childViewControllers[0] as! SettingsTableViewController
//        settingController.isGoToNotes = true
//        self.tabBarController?.selectedIndex = 4
//    }
    private func logout(){
        let refreshAlert = UIAlertController(title: "Logout", message: "Are you realy want to logout.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.logoutInternal()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        logout()
    }
    
    private func logoutInternal(){
        PreferencesUtil.sharedInstance.resetDefaults()
        //self.performSegue(withIdentifier: "showLoginViewController", sender: nil)
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func eventAction(_ sender: Any) {
        getEvents()
    }
    
//    @IBAction func profileAction(_ sender: Any) {
//        let controller = self.tabBarController?.viewControllers![4]
//        let settingController = controller?.childViewControllers[0] as! SettingsTableViewController
//        settingController.isGoToProfile = true
//        self.tabBarController?.selectedIndex = 4
//    }
    var loggedInUserSeq:Int = 0
    var loggedInCompanySeq:Int = 0
    var  progressHUD: ProgressHUD!
    var refreshControl:UIRefreshControl!
    override func viewDidLoad() {
        //setbackround()
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        userImageView.layer.borderWidth = 3
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.clipsToBounds = true
        
        notificationsView.layer.cornerRadius = 12
        notificationsView.layer.shadowColor = UIColor.darkGray.cgColor
        notificationsView.layer.shadowOffset = CGSize(width: 2, height: 2)
        notificationsView.layer.shadowOpacity = 0.8
        notificationsView.layer.shadowRadius = 6.0
        
        messagesView.layer.cornerRadius = 12
        messagesView.layer.shadowColor = UIColor.darkGray.cgColor
        messagesView.layer.shadowOffset = CGSize(width: 2, height: 2)
        messagesView.layer.shadowOpacity = 0.8
        messagesView.layer.shadowRadius = 6.0
        
        chatroomsView.layer.cornerRadius = 12
        chatroomsView.layer.shadowColor = UIColor.darkGray.cgColor
        chatroomsView.layer.shadowOffset = CGSize(width: 2, height: 2)
        chatroomsView.layer.shadowOpacity = 0.8
        chatroomsView.layer.shadowRadius = 6.0
        
        updateProfileView.layer.cornerRadius = 12
        updateProfileView.layer.shadowColor = UIColor.darkGray.cgColor
        updateProfileView.layer.shadowOffset = CGSize(width: 2, height: 2)
        updateProfileView.layer.shadowOpacity = 0.8
        updateProfileView.layer.shadowRadius = 6.0
        
        notesView.layer.cornerRadius = 12
        notesView.layer.shadowColor = UIColor.darkGray.cgColor
        notesView.layer.shadowOffset = CGSize(width: 2, height: 2)
        notesView.layer.shadowOpacity = 0.8
        notesView.layer.shadowRadius = 6.0
        
        trainingsView.layer.cornerRadius = 12
        trainingsView.layer.shadowColor = UIColor.darkGray.cgColor
        trainingsView.layer.shadowOffset = CGSize(width: 2, height: 2)
        trainingsView.layer.shadowOpacity = 0.8
        trainingsView.layer.shadowRadius = 6.0
        
        
        eventsView.layer.cornerRadius = 12
        eventsView.layer.shadowColor = UIColor.darkGray.cgColor
        eventsView.layer.shadowOffset = CGSize(width: 2, height: 2)
        eventsView.layer.shadowOpacity = 0.8
        eventsView.layer.shadowRadius = 6.0
        
        achievementsView.layer.cornerRadius = 12
        achievementsView.layer.shadowColor = UIColor.darkGray.cgColor
        achievementsView.layer.shadowOffset = CGSize(width: 2, height: 2)
        achievementsView.layer.shadowOpacity = 0.8
        achievementsView.layer.shadowRadius = 6.0
        
        changePasswordView.layer.cornerRadius = 12
        changePasswordView.layer.shadowColor = UIColor.darkGray.cgColor
        changePasswordView.layer.shadowOffset = CGSize(width: 2, height: 2)
        changePasswordView.layer.shadowOpacity = 0.8
        changePasswordView.layer.shadowRadius = 6.0
        
        logoutView.layer.cornerRadius = 12
        logoutView.layer.shadowColor = UIColor.darkGray.cgColor
        logoutView.layer.shadowOffset = CGSize(width: 2, height: 2)
        logoutView.layer.shadowOpacity = 0.8
        logoutView.layer.shadowRadius = 6.0
        
        
        //scrollView.contentSize.height = 700
        scrollView.layoutIfNeeded()
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: scrollView.frame.size.height)
        //self.topView.backgroundColor = UIColor(patternImage: UIImage(named: "topview_back_blue.jpg")!)
        progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        //getDashboardCounts()
        //getDashboardStates()
        synchCompanyUsers()
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshDashboard), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(connected(_:)))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func connected(_ sender:AnyObject){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UpdateProfileController") as! UpdateProfileViewController
        self.navigationController!.pushViewController(nextViewController, animated:true)
    }
    
   
    @objc func refreshDashboard(refreshControl: UIRefreshControl) {
        getDashboardCounts()
        getDashboardStates()
        populateUserInfoFromLocal()
    }
    func populateUserInfoFromLocal(){
       let user =  UserMgr.sharedInstance.getUserByUserSeq(userSeq: loggedInUserSeq)
       let userName = user?.fullname
       var userImageName = user?.imagename
       let compmanyImage = user?.companyimage
       let vendorLogo = user?.vendorlogo
        
       if(userImageName == nil){
           userImageName = "dummy.jpg"
       }
       let imageUrl = StringConstants.USER_IMAGE_URL + userImageName!
        var companyImageUrl = ""
        if(compmanyImage != nil){
            companyImageUrl = StringConstants.IMAGE_URL + "CompanyImages/companylogo/"+compmanyImage!
        }
        var vendorLogoUrl = ""
        if(vendorLogo != nil){
            vendorLogoUrl = StringConstants.IMAGE_URL + "AdminImages/vendorLogo/"+vendorLogo!
        }
       let userProfiles = user?.profiles
//       if let url = NSURL(string: imageUrl) {
//            if let data = NSData(contentsOf: url as URL) {
//                userImageView.image = UIImage(data: data as Data)
//            }
//        }
        if let url = NSURL(string: imageUrl) {
            DispatchQueue.global().async {
                if let data = NSData(contentsOf: url as URL) {
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: data as Data)
                    }
                }
            }
        }
        userNameLabel.text = userName
        userProfileLabel.text = userProfiles
        self.companyLogo.isHidden = true
        if(companyImageUrl != ""){
            if let url = NSURL(string: companyImageUrl) {
                DispatchQueue.global().async {
                    if let data = NSData(contentsOf: url as URL) {
                        DispatchQueue.main.async {
                            self.companyLogo.image = UIImage(data: data as Data)
                        }
                    }
                }
                self.companyLogo.isHidden = false
            }
        }
        self.vendorLogo.isHidden = true
        if(vendorLogoUrl != ""){
            if let url = NSURL(string: vendorLogoUrl) {
                DispatchQueue.global().async {
                    if let data = NSData(contentsOf: url as URL) {
                        DispatchQueue.main.async {
                            self.vendorLogo.image = UIImage(data: data as Data)
                        }
                    }
                }
                self.vendorLogo.isHidden = false
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        getDashboardStates()
        getDashboardCounts()
        populateUserInfoFromLocal()
        handleNotificationData()
    }
    
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.scrollView.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }

    
   
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
   
    
    private func handleNotificationData(){
        let isNotificationState = PreferencesUtil.sharedInstance.isNotificationState()
        if(isNotificationState){
            let data = PreferencesUtil.sharedInstance.getNotificationData()
            let entityType = data["entityType"]
            let entitySeq = Int(data["entitySeq"]!)!
            if(entityType == "module"){
                let lpSeq = Int(data["lpSeq"]!)!
                let navController = self.tabBarController?.viewControllers![1] as!  UINavigationController
                let moduleViewController = navController.viewControllers.first as! LearningTabController
                moduleViewController.isLaunch = true
                moduleViewController.selectedModuleSeq = entitySeq
                moduleViewController.selectedLpSeq = lpSeq
                PreferencesUtil.sharedInstance.resetNotificationData()
                self.tabBarController?.selectedIndex = 1
            }else if(entityType == "badge"){
                PreferencesUtil.sharedInstance.resetNotificationData()
                self.performSegue(withIdentifier: "Achievements", sender: nil)
            }else if(entityType == "chatroom" || entityType == "classroom"){
                PreferencesUtil.sharedInstance.resetNotificationData()
                self.performSegue(withIdentifier: "Notifications", sender: nil)
            }
            else {
                let fromUserName = data["fromUserName"]
                let navController = self.tabBarController?.viewControllers![3] as!  UINavigationController
                let messageViewController = navController.viewControllers.first as! MessageTableViewController
                messageViewController.isGoToMessageDetail = true
                messageViewController.selectedMessageUserSeq = entitySeq
                messageViewController.selectedMessageUserName = fromUserName!
                messageViewController.selectedMessageUserType = entityType!
                PreferencesUtil.sharedInstance.resetNotificationData()
                self.tabBarController?.selectedIndex = 2
            }
        }
    }
    func synchCompanyUsers(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.SYNCH_USERS, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        CompanyUserMgr.sharedInstance.saveUsersFromResponse(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    fileprivate func getEvents(){
        progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_EVENTS, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.progressHUD.hide()
                        self.populateEvents(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func populateEvents(response:[String: Any]){
        let annualViewController = SSCalendarAnnualViewController(events: generateEvents(eventsJson: response))
        self.navigationController!.navigationBar.isTranslucent = false
        annualViewController?.title = "Events"
        self.navigationController!.pushViewController(annualViewController!, animated: true)
        changeNavBarColor()
        
    }
    func changeNavBarColor(){
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageFromColor(color: UIColor.white), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    fileprivate func generateEvents(eventsJson:[String:Any]) -> [SSEvent] {
        var events: [SSEvent] = []
        let eventsArr = eventsJson["chatrooms"] as! [Any]
        for i in 0..<eventsArr.count{
            let eventJson = eventsArr[i] as! [String: Any]
            let title = eventJson["title"] as! String
            let detail = eventJson["detail"] as! String
            let startDateStr = eventJson["from"] as! String
            let endDateStr = eventJson["to"] as! String
            let event = SSEvent()
            let startDate = DateUtil.sharedInstance.stringToDate(dateStr: startDateStr)
            event.startDate = startDate
            event.startTime = DateUtil.sharedInstance.dateToString(date: startDate, format: DateUtil.time_format)
            let endDate = DateUtil.sharedInstance.stringToDate(dateStr: endDateStr)
            let dateDiffArr = DateUtil.sharedInstance.getDatesDiff(start: startDate, end: endDate)
            event.name = title
            event.desc = detail
            events.append(event)
            if(!dateDiffArr.isEmpty){
                for date in dateDiffArr{
                    let eventN = SSEvent()
                    eventN.name = event.name
                    eventN.desc = event.desc
                    eventN.startTime = event.startTime
                    eventN.startDate = date
                    events.append(eventN)
                }
            }
        }
        return events
    }
    func getDashboardCounts(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_COUNTS, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.populateDashboardCounts(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    func getDashboardStates(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_DASHBOARD_COUNTS, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.populateDashboardStats(response: json)
                    }else{
                        let isEnabled = json["isenabled"] as! Bool
                        if(!isEnabled){
                            self.logoutInternal()
                            return
                        }else{
                            self.showAlert(message: message!)
                        }
                        
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    func populateDashboardCounts(response: [String: Any]){
        let responseJson = response["dashboardCounts"] as! [String:Any]
        let pendingLpCount = responseJson["pendingLpCount"] as! Int
        let notificationCount = responseJson["notificationCount"] as! Int
        let mesasgeCount = responseJson["messages"] as! Int
        if(pendingLpCount > 0){
            self.pendingLpCount.text =  "+" + String(pendingLpCount)
        }else{
            self.pendingLpCount.text = ""
        }
        if(notificationCount > 0){
            self.notificationsCount.text = "+" + String(notificationCount)
        }else{
            self.notificationsCount.text = ""
        }
        if(mesasgeCount > 0){
            self.messagesCount.text = "+" + String(mesasgeCount)
        }else{
            self.messagesCount.text = ""
        }
        progressHUD.hide()
    }
    
    func populateDashboardStats(response: [String: Any]){
        let responseJson = response["dashboardData"] as! [String:Any]
        let totalScore = responseJson["totalScores"] as! Int
        let point = responseJson["points"] as! Int
        let pendingTrainings = responseJson["pendingTrainings"] as! [String:Any]
        let maxScore = pendingTrainings["maxScore"] as! Int
        var userRankStr = responseJson["userRank"] as? Int
        if(userRankStr == nil){
            userRankStr = 0
        }
        let pendingCount = pendingTrainings["pendingCount"] as! Int
        let totalScoreStr = String(totalScore) + "/" + String(maxScore)
        rankLabel.text = String(userRankStr!)
        scoreLabel.text = totalScoreStr
        self.points.text = String(point)
        progressHUD.hide()
        populateUserInfoFromLocal()
        if #available(iOS 10.0, *) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
