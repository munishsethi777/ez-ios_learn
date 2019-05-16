//
//  MessageTableViewController.swift
//  RightManagement
//
//  Created by Munish Sethi on 10/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class MessageTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var messageTableView: UITableView!
    var messages = [Message]()
    var loggedInUserSeq: Int = 0
    var loggedInCompanySeq: Int = 0
    var messageCount: Int = 0
    var selectedMessageUserSeq:Int = 0
    var selectedMessageUserName:String = ""
    var selectedMessageUserType:String = ""
    var refreshControl:UIRefreshControl!
    var  progressHUD: ProgressHUD!
    var cache:NSCache<AnyObject, AnyObject>!
    var isGoToMessageDetail = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //setbackround()
        cache  = NSCache()
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
       // getMessages()
        messageTableView.delegate = self
        messageTableView.dataSource = self
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
            messageTableView.refreshControl = refreshControl
        }
        progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        if(isGoToMessageDetail){
            goToMessageDetail()
        }
    }
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.messageTableView.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessages()
        changeNavBarColor()
    }
    func changeNavBarColor(){
        self.navigationController?.navigationBar.tintColor = .black
        let color = UIColor.init(red: 231/255.0, green: 124/255.0, blue: 34/255.0, alpha: 0.5)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageFromColor(color: color), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    @objc func refreshView(refreshControl: UIRefreshControl) {
        cache  = NSCache()
        getMessages()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        selectedMessageUserSeq = message.chattingUserSeq
        selectedMessageUserType = message.chattingUserType
        selectedMessageUserName = message.messageTitle
        if(!message.isRead){
            let cell = tableView.cellForRow(at: indexPath) as! MessageTableViewCell
            cell.messageDescription.font = UIFont.systemFont(ofSize: 12)
            cell.messageDescription.textColor = UIColor.darkGray
            markAsRead(row: indexPath.row)
        }
        self.performSegue(withIdentifier: "MessageDetailViewController", sender: nil)
    }
    
    func goToMessageDetail(){
        self.performSegue(withIdentifier: "MessageDetailViewController", sender: nil)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MessageTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageTableViewCell
        let message = messages[indexPath.row]
        cell?.messageTitle.text = message.messageTitle
        cell?.messageDescription.font = UIFont.systemFont(ofSize: 12)
        cell?.messageDescription.textColor = UIColor.darkGray
        if(!message.isRead){
            cell?.messageDescription.font = UIFont.boldSystemFont(ofSize: 12)
            cell?.messageDescription.textColor = UIColor.black
        }
        cell?.messageDescription.text = message.messageDescription
        cell?.messageDateLabel.text = message.date
        if (self.cache.object(forKey: indexPath.row as AnyObject) != nil){
            cell?.messageImageView?.image = self.cache.object(forKey: indexPath.row as AnyObject) as? UIImage
        }else {
            let imagePath = message.userImageUrl
            if let url = NSURL(string: imagePath) {
                if let data = NSData(contentsOf: url as URL) {
                    let img = UIImage(data: data as Data)
                    cell?.messageImageView.image = img
                    cell?.messageImageView.layer.cornerRadius = (cell?.messageImageView.frame.height)! / 2
                    cell?.messageImageView.clipsToBounds = true
                    self.cache.setObject(img!, forKey: indexPath.row as AnyObject)
                }
            }
        }
        return cell!
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func markAsRead(row:Int){
        let messageObj = messages[row]
        let messageSeq = messageObj.messageSeq
        let chatUserSeq = messageObj.chattingUserSeq
        let chatUserType = messageObj.chattingUserType
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,chatUserSeq,chatUserType,1]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.MESSAGE_MARK_AS_READ, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        messageObj.isRead = true
                        self.messages[row] = messageObj
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func getMessages(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_MESSSAGES, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadMessages(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loadMessages(response: [String: Any]){
        let messageJsonArr = response["messages"] as! [Any];
        messageCount = messageJsonArr.count
        messages.removeAll()
        for i in 0..<messageJsonArr.count{
            let messageJson = messageJsonArr[i] as! [String: Any]
            let seq = messageJson["seq"] as! String
            let title = messageJson["messageText"] as! String
            let dated = messageJson["dated"] as! String
            let name = messageJson["name"] as! String
            let userImage = messageJson["userImage"] as! String
            let userImageUrl = StringConstants.WEB_API_URL + userImage
            let userType = messageJson["userType"] as! String
            let userSeq = messageJson["userSeq"] as! String
           // let fromSeq  = messageJson["fromseq"] as! String
            let readInt = messageJson["isRead"] as! Int
            var isRead = readInt == 1;
            //check sent by itself
            //if(userType != "admin" && Int(fromSeq)! == self.loggedInUserSeq){
            //    isRead = true
            //}
            let msg = Message(seq: Int(seq)!,messageTitle:name,messageDescription: title,userImageUrl:userImageUrl,date:dated,chattingUserSeq:Int(userSeq)!,chattingUserType:userType,isRead:isRead)
            messages.append(msg)
        }
        progressHUD.hide()
        if #available(iOS 10.0, *) {
            refreshControl.endRefreshing()
        }
        messageTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "MessageDetailViewController") {
            let destinationVC:MessageChatController = segue.destination as! MessageChatController
            destinationVC.chatUserSeq = selectedMessageUserSeq
            destinationVC.charUserType = selectedMessageUserType
            destinationVC.chattingUserName = selectedMessageUserName
        }
    }
    
    

}
