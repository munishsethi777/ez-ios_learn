//
//  DashboardVC.swift
//  RightManagement
//
//  Created by Munish Sethi on 10/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class DashboardVC:UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
   
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var activeLearningPlansHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var pointsView: UIView!
    @IBOutlet weak var trainingView: UIView!
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var activeLearningPlanCollectionView: UICollectionView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var completedCountLabel: UILabel!
    @IBOutlet weak var pendingCountLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    var selectedChatroomId:Int!
    var selctedChatroomName:String!
    
    var notifications = [NotificationObj]()
    var activeLearningPlans = [ActiveLearningPlan]()
    var loggedInUserSeq: Int = 0
    var loggedInCompanySeq: Int = 0
    var notificationsCount: Int = 0
    var activeLpCount: Int = 0
    var action_name: String = ""
    var refreshControl:UIRefreshControl!
    var  progressHUD: ProgressHUD!
    var moduleSeq = 0
    override func viewDidLoad() {
        rankView.layer.cornerRadius = 8
        scoreView.layer.cornerRadius = 8
        pointsView.layer.cornerRadius = 8
        trainingView.layer.cornerRadius = 8
        
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        
        activeLearningPlanCollectionView.delegate = self
        activeLearningPlanCollectionView.dataSource = self
        self.loggedInUserSeq =  PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        self.loggedInCompanySeq =  PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        getDashboardStates()
        getActiveLearningPlans()
        synchCompanyUsers()
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshDashboard), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
        // Create and add the view to the screen.
        progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        //showAlert(message: UIDevice.current.identifierForVendor!.uuidString)
        
        // All done!
    }
    override func viewWillAppear(_ animated: Bool) {
        handleNotificationData()
    }
    @objc func refreshDashboard(refreshControl: UIRefreshControl) {
        getDashboardStates()
        getNotifications()
        getActiveLearningPlans()
    }
    
    func resetScrollHeight(){
        var scrollheight: CGFloat = 90
        scrollheight += self.notificationTableViewHeightConstraint.constant
        scrollheight += self.activeLearningPlansHeightConstraint.constant
        scrollheight += self.topView.frame.height
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height:scrollheight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCell: CGFloat = 2  //you need to give a type as CGFloat
        let cellWidth = UIScreen.main.bounds.size.width / numberOfCell
        return CGSize(width: cellWidth-1, height: 73)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NotificationTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell
        let notification = notifications[indexPath.row]
        cell?.notificationTitle.text = notification.title
        cell?.notificationButton.setTitle(notification.notificationType, for: UIControlState.normal)
        cell?.notificationButton.tag = indexPath.row
        cell?.notificationButton.removeTarget(self, action:#selector(nominateTraining), for: .touchUpInside)
        if(notification.notificationType == "Chatroom"){
            cell?.notificationButton.addTarget(self, action:#selector(launchChatroom), for: .touchUpInside)
        }else if(notification.notificationType == "Nominate"){
            cell?.notificationButton.addTarget(self, action:#selector(nominateTraining), for: .touchUpInside)
        }else if (notification.notificationType == "Classroom"){
            cell?.notificationButton.addTarget(self, action:#selector(goToEvents), for: .touchUpInside)
        }
        return cell!
    }
    @objc func goToEvents(){
        let controller = self.tabBarController?.viewControllers![4]
        let settingController = controller?.childViewControllers[0] as! SettingsTableViewController
        settingController.isGotoEvents = true
        self.tabBarController?.selectedIndex = 4
    }
    private func handleNotificationData(){
        let isNotificationState = PreferencesUtil.sharedInstance.isNotificationState()
        if(isNotificationState){
            let data = PreferencesUtil.sharedInstance.getNotificationData()
            let entityType = data["entityType"]
            if(entityType == "module"){
                self.tabBarController?.selectedIndex = 1
            }else{
                PreferencesUtil.sharedInstance.resetNotificationData()
                let controller = self.tabBarController?.viewControllers![4]
                let settingController = controller?.childViewControllers[0] as! SettingsTableViewController
                settingController.isGotoAchivement = true
                self.tabBarController?.selectedIndex = 4
            }
        }
    }
    @objc func nominateTraining(sender:UIButton){
        let index = sender.tag
        let notification = notifications[index]
        let tSeq = notification.seq
        let lpSeq = 0
        let refreshAlert = UIAlertController(title: "Nominate", message: StringConstants.NOMINATE_TRAINING_CONFIRM, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.excuteNominateTraining(trainingSeq:tSeq,lpSeq: lpSeq)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func excuteNominateTraining(trainingSeq:Int,lpSeq:Int){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq,trainingSeq,lpSeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.NOMINATE_TRAINING, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.getNotifications()
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    @objc func launchChatroom(sender:UIButton){
        let index = sender.tag
        let notification = notifications[index]
        selectedChatroomId = notification.seq
        selctedChatroomName = notification.title
        self.tabBarController?.selectedIndex = 3
        let controller = self.tabBarController?.viewControllers![3]
        let navigationController = controller?.childViewControllers[0] as! UINavigationController
        let chatController = navigationController.viewControllers[0] as! ChatViewController
        chatController.selectedChatroomId = selectedChatroomId
        chatController.selctedChatroomName = selctedChatroomName
        chatController.isCalledFromDashboard = true
        self.tabBarController?.selectedIndex = 3
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.activeLpCount
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "ActiveLearningPlanCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ActiveLearningPlanCollectionViewCell
        cell?.ring.sizeToFit();
        cell?.ring.font = UIFont.systemFont(ofSize: 12)
        let learningPlan = activeLearningPlans[indexPath.row]
        cell?.learningPlanTitle.text = learningPlan.learningPlanName
        let progress = Float(learningPlan.percentageCompleted)
        cell?.ring.setProgress(value: CGFloat(progress), animationDuration: 2)
        return cell!
    }
    
    func loadNotificaitons(response: [String: Any]){
        let notificationJsonArr = response["notifications"] as! [Any]
        self.notificationsCount = notificationJsonArr.count
        notifications = []
        for var i in (0..<notificationJsonArr.count).reversed(){
            let notificationJson = notificationJsonArr[i] as! [String:Any]
            let seq = notificationJson["seq"] as! String
            let title = notificationJson["title"] as? String
            let from = notificationJson["from"] as? String
            let type = notificationJson["type"] as! String
            let status = notificationJson["status"] as? String
            let fromDate = DateUtil.sharedInstance.stringToDate(dateStr: from!)
            let fromDateInFormat = DateUtil.sharedInstance.dateToString(date: fromDate, format: DateUtil.format)
            let Detail = title! + " on " + fromDateInFormat
            var notificationType = "Nominate"
            if(type == "currentlyActiveEvent"){
                if let eventType = notificationJson["eventtype"] as? String, eventType == "chatroom"
                {
                    notificationType = "Chatroom"
                }else{
                    notificationType = "Classroom"
                }
            }else{
                if(status == "unapproved"){
                    notificationType = "Nominated"
                }
            }
            let not1 = NotificationObj(seq:Int(seq)!,title:Detail,notificationType: notificationType,isRead: false,entitySeq:0)
            notifications.append(not1)
        }
        self.notificationsTableView.reloadData()
        self.notificationTableViewHeightConstraint.constant = self.notificationsTableView.contentSize.height
        resetScrollHeight()
    }
    
    func loadActiveLearningPlans(response: [String: Any]){
        let lpJsonArr = response["learningPlans"] as! [Any]
        self.activeLpCount = lpJsonArr.count
        for var i in (0..<lpJsonArr.count).reversed(){
            let lpJson = lpJsonArr[i] as! [String:Any]
            let title = lpJson["learningPlanName"] as! String
            let progress = lpJson["percentCompleted"] as! Double
            let alp = ActiveLearningPlan(learningPlanSeq: 1, learningPlanName: title,percentageCompleted: Int(progress))
            activeLearningPlans.append(alp)
        }
        activeLearningPlanCollectionView.reloadData()
        self.activeLearningPlansHeightConstraint.constant = self.activeLearningPlanCollectionView.collectionViewLayout.collectionViewContentSize.height
        resetScrollHeight()
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
    
    func getNotifications(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_NOTIFICATION, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadNotificaitons(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func getActiveLearningPlans(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_LEARNING_PLAN, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadActiveLearningPlans(response: json)
                        if #available(iOS 10.0, *) {
                            self.refreshControl.endRefreshing()
                        }
                        self.progressHUD.hide()
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }

    
    func populateDashboardCounts(response: [String: Any]){
        let responseJson = response["dashboardData"] as! [String:Any]
        let totalScore = responseJson["totalScores"] as! Int
        let completedTrainings = responseJson["completedTrainings"] as! Int
        let pendingTrainings = responseJson["pendingTrainings"] as! [String:Any]
        let maxScore = pendingTrainings["maxScore"] as! Int
        var userRankStr = responseJson["userRank"] as? Int
        if(userRankStr == nil){
            userRankStr = 0
        }
        let pendingCount = pendingTrainings["pendingCount"] as! Int
        let totalScoreStr = String(totalScore) + "/" + String(maxScore)
        rankLabel.text = String(userRankStr!)
        totalScoreLabel.text = totalScoreStr
        pendingCountLabel.text = String(pendingCount)
        completedCountLabel.text = String(completedTrainings)
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "MessageBox", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
