//
//  ChatDetailController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 04/01/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
class ChatDetailController:UIViewController,InputbarDelegate,MessageGatewayDelegate,UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var chatBackgroundImage: UIImageView!
    @IBOutlet weak var inputbar: Inputbar!
    @IBOutlet weak var tableView: UITableView!
    var chat:Chat! {
        didSet {
            self.title = self.chat.contact.name
        }
    }
    var chatRoomId:Int = 0
    var chatRoomName:String!
    var loggedInUserSeq:Int = 0
    var loggedInCompanySeq:Int = 0
    var loggedInUserName:String!
    var isCallFromNotification = false;
    var syncMessageScheduler = Timer()
    private var tableArray:TableArray!
    private var gateway:MessageGateway!
    override func viewDidLoad() {
        super.viewDidLoad()
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        loggedInUserName = PreferencesUtil.sharedInstance.getLoggedInUserName()
        //Where tableview is the IBOutlet for your storyboard tableview.
        getMessages(isScroll: true)
        syncMessages()
    }
    
   

    @IBAction func userTapped(_ sender: Any) {
         self.inputbar.inputResignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          if(isCallFromNotification){
                var toolBarFrame = self.inputbar.frame
                let toolBarY = toolBarFrame.origin.y
                let viewHeight = self.parent?.view.frame.height
                let y = toolBarY - (toolBarFrame.height + 5)
                toolBarFrame.origin.y = y
                self.inputbar.frame = toolBarFrame
            }
    }
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        
        //self.view.keyboardTriggerOffset = inputbar.frame.size.height
        self.view.addKeyboardPanning() {[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            /*
             self.view.removeKeyboardControl()
             */
            var toolBarFrame = self.inputbar.frame
            let tabbarFrame = self.parent?.tabBarController?.tabBar.frame
            var toolbarY = keyboardFrameInView.origin.y - toolBarFrame.size.height
            if(closing == true){
                toolbarY -= (tabbarFrame?.size.height)!
            }
            toolBarFrame.origin.y = toolbarY
            self.inputbar.frame = toolBarFrame
            
            var tableViewFrame = self.tableView.frame
            let tableViewY = toolBarFrame.origin.y + (tabbarFrame?.size.height)!
            
            tableViewFrame.size.height = tableViewY - 64
            self.tableView.frame = tableViewFrame
            self.tableViewScrollToBottomAnimated(animated: false)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
        self.view.removeKeyboardControl()
        self.gateway.dismiss()
    }
    
    
    override func viewWillDisappear(_ animated:Bool) {
        self.chat.lastMessage = self.tableArray!.lastObject()
    }
    
    // MARK -
    
    func setInputbar() {
        self.inputbar.placeholder = nil
        self.inputbar.inputDelegate = self
        self.inputbar.leftButtonImage = UIImage(named:"share")
        self.inputbar.rightButtonText = "Send"
        self.inputbar.rightButtonTextColor = UIColor(red:0, green:124/255, blue:1, alpha:1)
    }
    
    func setTableView() {
        self.tableArray = TableArray()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x:0, y:0,width:self.view.frame.size.width,height:10))
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.register(MessageCell.self, forCellReuseIdentifier:"MessageCell")
    }
    
    func setGateway(scroll:Bool) {
        self.gateway = MessageGateway.sharedInstance
        self.gateway.delegate = self
        self.gateway.chat = self.chat
        self.gateway.loadOldMessages()
        if(scroll){
            tableViewScrollToBottomAnimated(animated: false)
        }
    }
    
    // MARK - Actions
    
    @IBAction func userDidTapScreen(_ sender: Any) {
        self.inputbar.inputResignFirstResponder()
    }
    
    // MARK - TableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableArray.numberOfSections
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableArray.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray.numberOfMessagesInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.message = self.tableArray.objectAtIndexPath(indexPath: indexPath as NSIndexPath)
        return cell;
    }
    
    // MARK - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.tableArray.objectAtIndexPath(indexPath: indexPath as NSIndexPath)
        return message.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableArray.titleForSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x:0,y: 0,width: tableView.frame.size.width,height: 40)
        
        let view = UIView(frame:frame)
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = .flexibleWidth
        
        let label = UILabel()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textAlignment = .center
        label.font = UIFont(name:"Helvetica", size:20)
        label.sizeToFit()
        label.center = view.center
        label.font = UIFont(name:"Helvetica", size:13)
        label.backgroundColor = UIColor(red:207/255, green:220/255, blue:252/255, alpha:1)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.autoresizingMask = []
        view.addSubview(label)
        return view
    }
    
    func tableViewScrollToBottomAnimated(animated:Bool) {
        let numberOfSections = self.tableArray.numberOfSections
        let numberOfRows = self.tableArray.numberOfMessagesInSection(section: numberOfSections-1)
        if numberOfRows > 0 {
            self.tableView.scrollToRow(at: self.tableArray.indexPathForLastMessage() as IndexPath, at:.bottom, animated:animated)
        }
    }
    
    
    
    // MARK - InputbarDelegate
    
    func inputbarDidPressRightButton(inputbar:Inputbar) {
        let message = MessageDetail()
        message.text = inputbar.text
        message.date = NSDate()
        message.chatId = String(chatRoomId)
        //Store Message in memory
        self.tableArray.addObject(message: message)
        
        //Insert Message in UI
        let indexPath = self.tableArray.indexPathForMessage(message: message)
        self.tableView.beginUpdates()
        if self.tableArray.numberOfMessagesInSection(section: indexPath.section) == 1 {
            self.tableView.insertSections(NSIndexSet(index:indexPath.section) as IndexSet, with:.none)
        }
        self.tableView.insertRows(at: [indexPath as IndexPath], with:.bottom)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: self.tableArray.indexPathForLastMessage() as IndexPath, at:.bottom, animated:true)
        
        //Send message to server
        
        
        sendMessage(messageDetail: message)
    }
    func inputbarDidPressLeftButton(inputbar:Inputbar) {
        let alertView = UIAlertView(title: "Left Button Pressed", message: nil, delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    func inputbarDidChangeHeight(newHeight:CGFloat) {
        //Update DAKeyboardControl
        self.view.keyboardTriggerOffset = newHeight
    }
    
    // MARK - MessageGatewayDelegate
    
    func gatewayDidUpdateStatusForMessage(message:MessageDetail) {
        let indexPath = self.tableArray.indexPathForMessage(message: message)
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! MessageCell
        cell.updateMessageStatus()
    }
    
    func gatewayDidReceiveMessages(array:[MessageDetail]) {
        self.tableArray.addObjectsFromArray(messages: array)
        self.tableView.reloadData()
    }
    
    @objc func getMessages(isScroll:Bool){
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,self.chatRoomId,0]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_CHATROOM_DETAIL, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadMessageDetail(response: json)
                        self.setInputbar()
                        self.setTableView()
                        self.setGateway(scroll: isScroll)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func sendMessage(messageDetail: MessageDetail){
        let messageText = messageDetail.text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,self.chatRoomId,"user",loggedInUserName,0,messageText]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.SEND_CHAT_MESSAGE, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        messageDetail.status = .Received
                        self.gateway.sendMessage(message: messageDetail)
                    }else{
                        self.showAlert(message: message!)
                    }
                    
                    
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func loadMessageDetail(response:[String: Any]){
        LocalStorage.sharedInstance.refreshStorage()
        let messageDetailArr = response["messages"] as! [Any];
        let contact = Contact()
        contact.name = chatRoomName
        contact.identifier = String(chatRoomId)
        let chat = Chat()
        chat.contact = contact
        for i in 0..<messageDetailArr.count{
            let messageDetailJson = messageDetailArr[i] as! [String: Any]
            let chatSeq = messageDetailJson["post_id"] as! String
            let datedStr = messageDetailJson["post_time"] as! String
            let postDate = messageDetailJson["post_date"] as! String + "000"
            var name = messageDetailJson["uname"] as? String
            let milisecond = postDate
            let date = Date.init(timeIntervalSince1970: TimeInterval(milisecond)!/1000)
            let messagetext = messageDetailJson["post_message"] as! String
            let fromUserName = messageDetailJson["post_user"] as! String
            let type = messageDetailJson["user_type"] as! String
            
            let isSent = loggedInUserName == fromUserName;
            let message = MessageDetail()
            message.text = messagetext
            message.sender = .Someone
            if(type == "admin"){
                name = messageDetailJson["aname"] as? String;
            }else {
                if(name == nil || name == "" || name == "null"){
                    name =   fromUserName;
                }
            }
            message.username = name!
            message.date = date as NSDate
            if(isSent){
                message.status = .Received
                message.sender = .Myself
            }else{
                message.status = .Received
            }
            message.chatId = String(chatRoomId)
            LocalStorage.sharedInstance.storeMessage(message: message)
        }
        self.chat = chat
        self.chat.numberOfUnreadMessages = messageDetailArr.count
    }
    
    func syncMessages(){
        syncMessageScheduler = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(self.getMessages), userInfo: nil, repeats: true)
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}


