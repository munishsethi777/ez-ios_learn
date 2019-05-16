//
//  NotificationViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 29/01/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
import SSCalendar
class NotificationViewController:UIViewController,UITableViewDataSource,UITableViewDelegate{
    var notifications = [NotificationObj]()
    var loggedInUserSeq: Int = 0
    var loggedInCompanySeq: Int = 0
    var notificationsCount: Int = 0
    var progressHUD: ProgressHUD!
    var selectedChatroomId:Int!
    var selctedChatroomName:String!
     var refreshControl:UIRefreshControl!
    @IBOutlet weak var notificationsTableView: UITableView!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setbackround()
        notificationsTableView.dataSource = self
        notificationsTableView.delegate = self
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        getNotifications()
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
            notificationsTableView.refreshControl = refreshControl
        }
    }
    @objc func refreshView(refreshControl: UIRefreshControl) {
        getNotifications()
    }
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.notificationsTableView.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // action two
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.delete(tableView:tableView,index:indexPath)
        })
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NotificationTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell
        let notification = notifications[indexPath.row]
        cell?.notificationTitle.text = notification.title
        cell?.typeLabel.text = notification.notificationType
        //cell?.notificationButton.setTitle(notification.notificationType, for: UIControlState.normal)
        cell?.notificationButton.tag = indexPath.row
        cell?.notificationButton.removeTarget(self, action:#selector(nominateTraining), for: .touchUpInside)
        cell?.notificationImageView.image = UIImage(named: "icons8-training-60")
        cell?.notificationImageView.isHidden = false
        if(notification.notificationType == "Chatroom"){
            cell?.notificationImageView.image = UIImage(named: "icons8-communication-60")
            cell?.notificationButton.addTarget(self, action:#selector(launchChatroom), for: .touchUpInside)
        }else if(notification.notificationType == "Nominate"){
            cell?.notificationButton.addTarget(self, action:#selector(nominateTraining), for: .touchUpInside)
        }else if (notification.notificationType == "Classroom"){
            cell?.notificationButton.addTarget(self, action:#selector(goToEvents), for: .touchUpInside)
        }else if (notification.notificationType == "Module"){
            cell?.notificationButton.addTarget(self, action:#selector(launchModule), for: .touchUpInside)
        }else if (notification.notificationType == "Badge Allotted"){
            cell?.notificationImageView.image = UIImage(named: "icons8-prize-50")
            cell?.notificationButton.addTarget(self, action:#selector(goToAchievements), for: .touchUpInside)
        }else if(notification.notificationType == "Nominated"){
            cell?.notificationButton.addTarget(self, action:#selector(alreadyNominated), for: .touchUpInside)
        }else if(notification.notificationType == "Nomination Rejected"){
           
            cell?.notificationButton.isHidden = true
        }
        cell?.notificationImageView.layer.borderWidth = 2.5
        cell?.notificationImageView.layer.borderColor = UIColor.init(red: 231/255.0, green: 124/255.0, blue: 34/255.0, alpha: 1).cgColor
        cell?.notificationImageView.layer.cornerRadius = 16;
        cell?.notificationImageView.clipsToBounds = true
        cell?.contentView.sendSubview(toBack:(cell?.bottomView)!)
        cell?.bottomView.layer.borderWidth = 0.3
        cell?.bottomView.layer.borderColor = UIColor.lightGray.cgColor
        cell?.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        cell?.bottomView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell?.bottomView.layer.shadowOpacity = 0.5
        cell?.bottomView.layer.shadowRadius = 4.0
        cell?.bottomView.color = UIColor.init(red: 231/255.0, green: 124/255.0, blue: 34/255.0, alpha: 1)
        cell?.bottomView.commonInit()
        if(notification.isread){
            cell?.bottomView.setBackroundColor(color: UIColor.init(red: 231/255.0, green: 124/255.0, blue: 34/255.0, alpha: 0.2));
        }
        return cell!
    }
    
    @objc func alreadyNominated(){
        showAlert(message: "Training Already Nominated", title: "Nominated")
    }
    
    @objc func goToEvents(){
        getEvents()
    }
  
    private func delete(tableView:UITableView,index:IndexPath){
        let refreshAlert = UIAlertController(title: "Remove Notification", message: "Are you realy want to Remove this Notification?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.progressHUD.show()
            self.deleteNotification(tableView:tableView,index:index)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @objc func launchChatroom(sender:UIButton){
        let index = sender.tag
        let notification = notifications[index]
        selectedChatroomId = notification.entitySeq
        selctedChatroomName = notification.title
        self.performSegue(withIdentifier: "ChatroomDetailView", sender: nil)
    }
    
    @objc func launchModule(sender:UIButton){
        let index = sender.tag
        let notification = notifications[index]
        let launchModuleVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaunchModule") as! LaunchModuleViewController
        launchModuleVC.moduleSeq = notification.entitySeq
        launchModuleVC.lpSeq = 0
        self.present(launchModuleVC, animated: true, completion: nil)
    }
    
    @objc func goToAchievements(sender:UIButton){
       self.performSegue(withIdentifier: "MyAchievements", sender: nil)
    }
    
    @objc func nominateTraining(sender:UIButton){
        let index = sender.tag
        let notification = notifications[index]
        let tSeq = notification.entitySeq
        let lpSeq = 0
        let refreshAlert = UIAlertController(title: "Nominate", message: StringConstants.NOMINATE_TRAINING_CONFIRM, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.excuteNominateTraining(trainingSeq:tSeq,lpSeq: lpSeq)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func deleteNotification(tableView:UITableView,index:IndexPath){
        let notification = notifications[index.row]
        let notificationSeq = notification.seq
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,notificationSeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.DELETE_NOTIFICATION, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.notifications.remove(at: index.row)
                        self.progressHUD.hide()
                        tableView.deleteRows(at: [index], with: .fade)
                        //self.showAlert(message: message!,title:"Success")
                    }else{
                        self.showAlert(message: message!,title:"Failed")
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description,title:"Exception")
            }
        })
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
    func getNotifications(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_NOTIFICATIONS_NEW, args: args)
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
    
    
    func markAsReadCall(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.MARK_AS_READ_NOTIFICATION, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    func loadNotificaitons(response: [String: Any]){
        let notificationJsonArr = response["notifications"] as! [Any]
        self.notificationsCount = notificationJsonArr.count
        notifications = []
        var unReadCount = 0;
        for var i in 0..<notificationJsonArr.count{
            let notificationJson = notificationJsonArr[i] as! [String:Any]
            let seq = notificationJson["seq"] as! String
            let title = notificationJson["title"] as! String
            let entityType = notificationJson["entitytype"] as! String
            let entitySeq = notificationJson["entityseq"] as! String
            let from = notificationJson["startdate"] as? String
            let notificationType = notificationJson["notificationtype"] as! String
            let read = notificationJson["isread"] as! String
            var nType = "Nominate"
            var isRead = false;
            if(read == "0"){
                unReadCount = unReadCount + 1;
                isRead = true
            }
            if(entityType == "module"){
//                if(notificationType != "onEnrollment"){
//                    button.setVisibility(View.GONE);
//                    imageView_button.setVisibility(View.GONE);
//                }
                nType = "Module";
            }else if (entityType == "chatroom"
                && notificationType != "self_nomination") {
                nType = "Chatroom";
            } else if (entityType == "classroom"
                && notificationType != "self_nomination") {
                nType = "Classroom"
            } else if(entityType == "badge"){
                nType = "Badge Allotted";
            }
            if(notificationType == "nominated") {
                nType = "Nominated";
            }else if(notificationType == "reject"){
                nType = "Nomination Rejected"
            }
            let not1 = NotificationObj(seq:Int(seq)!,title:title,notificationType: nType,isRead:isRead,entitySeq:Int(entitySeq)!)
            notifications.append(not1)
        }
        progressHUD.hide()
        self.notificationsTableView.reloadData()
        if #available(iOS 10.0, *) {
            refreshControl.endRefreshing()
        }
        if(unReadCount > 0){
            markAsReadCall();
        }
    }
//    func loadNotificaitons1(response: [String: Any]){
//        let notificationJsonArr = response["notifications"] as! [Any]
//        self.notificationsCount = notificationJsonArr.count
//        notifications = []
//        for var i in 0..<notificationJsonArr.count{
//            let notificationJson = notificationJsonArr[i] as! [String:Any]
//            let seq = notificationJson["seq"] as! String
//            let title = notificationJson["title"] as? String
//            let from = notificationJson["from"] as? String
//            let type = notificationJson["type"] as! String
//            let status = notificationJson["status"] as? String
//            let fromDate = DateUtil.sharedInstance.stringToDate(dateStr: from!)
//            let fromDateInFormat = DateUtil.sharedInstance.dateToString(date: fromDate, format: DateUtil.format)
//            let Detail = title! + "\non " + fromDateInFormat
//            var notificationType = "Nominate"
//            if(type == "currentlyActiveEvent"){
//                if let eventType = notificationJson["eventtype"] as? String, eventType == "chatroom"
//                {
//                    notificationType = "Chatroom"
//                }else{
//                    notificationType = "Classroom"
//                }
//            }else{
//                if(status == "unapproved"){
//                    notificationType = "Nominated"
//                }
//            }
//            let not1 = Notification(seq:Int(seq)!,title:Detail,notificationType: notificationType)
//            notifications.append(not1)
//        }
//        progressHUD.hide()
//        self.notificationsTableView.reloadData()
//    }
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
        self.navigationController!.pushViewController(annualViewController!, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavBarColor()
    }
    func changeNavBarColor(){
        self.navigationController?.navigationBar.tintColor = .black
        let color = UIColor.init(red: 171/255.0, green: 64/255.0, blue: 75/255.0, alpha: 0.5)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageFromColor(color: color), for: .default)
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
    func showAlert(message: String,title:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func showAlert(message: String){
        let alert = UIAlertController(title: "MessageBox", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "ChatroomDetailView") {
            let destinationVC:ChatDetailController = segue.destination as! ChatDetailController
            destinationVC.chatRoomId = selectedChatroomId
            destinationVC.chatRoomName = selctedChatroomName
            destinationVC.isCallFromNotification = true;
        }else if (segue.identifier == "LaunchModule") {
                 let destinationVC:LaunchModuleViewController = segue.destination as! LaunchModuleViewController
                destinationVC.moduleSeq = selectedChatroomId
                destinationVC.lpSeq = 0
        }
     }
    
}

class baseView: UIView {
    
    let dashedBorder = CAShapeLayer()
    let backround = CAShapeLayer()
    var color = UIColor()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         //commonInit()
    }
    
     func commonInit() {
        //custom initialization
        dashedBorder.strokeColor = color.cgColor
        dashedBorder.fillColor = color.cgColor
        dashedBorder.path = UIBezierPath(rect: CGRect(x: self.frame.width, y: 0, width: 2, height: self.frame.height)).cgPath
        self.layer.addSublayer(dashedBorder)
        
    }
 
    func setBackroundColor(color:UIColor){
        self.layer.backgroundColor = color.cgColor
    }
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        dashedBorder.path = UIBezierPath(rect: CGRect(x: self.frame.width, y: 0, width: 2, height: self.frame.height)).cgPath
    }
}
