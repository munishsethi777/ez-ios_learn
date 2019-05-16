//
//  CreateNewMessageController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 05/01/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

//
//  MessageTableViewController.swift
//  RightManagement
//
//  Created by Munish Sethi on 10/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.

import UIKit

class CreateMessageTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageTableView: UITableView!
    
    var companyUsers = [CompanyUsers]()
    var loggedInUserSeq: Int = 0
    var loggedInCompanySeq: Int = 0
    var messageCount: Int = 0
    var selectedMessageUserSeq:Int = 0
    var selectedMessageUserName:String!
    var selectedMessageUserType:String = ""
    var filteredData = [CompanyUsers]()
     var  progressHUD: ProgressHUD!
    var cache:NSCache<AnyObject, AnyObject>!
    override func viewDidLoad() {
        super.viewDidLoad()
        rowCount = 1
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        messageTableView.dataSource = self
        messageTableView.delegate = self
        searchBar.delegate = self
        cache  = NSCache()
        getCompanyUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? companyUsers : companyUsers.filter({(companyUser: CompanyUsers) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return companyUser.fullname!.range(of: searchText, options: .caseInsensitive) != nil
        })
        messageTableView.reloadData()
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let companyuser = filteredData[indexPath.row]
        selectedMessageUserSeq = Int(companyuser.userseq)
        selectedMessageUserType = companyuser.usertype!
        selectedMessageUserName = companyuser.fullname
        self.performSegue(withIdentifier: "MessageDetailViewController", sender: nil)
    }
    var rowCount = 1
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MessageTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageTableViewCell
        let companyuser = filteredData[indexPath.row]
        cell?.messageTitle.text = companyuser.fullname
        var imageDirName = "UserImages/"
        if(companyuser.usertype != "user"){
            imageDirName = "AdminImages/";
        }
        if(companyuser.userimage == nil){
            companyuser.userimage = "dummy.jpg"
        }
        let imagePath = StringConstants.IMAGE_URL + imageDirName + companyuser.userimage!
        if (self.cache.object(forKey: indexPath.row as AnyObject) != nil){
            cell?.messageImageView?.image = self.cache.object(forKey: indexPath.row as AnyObject) as? UIImage
        }else if let url = NSURL(string: imagePath) {
            DispatchQueue.global().async {
               if let data = NSData(contentsOf: url as URL) {
                    DispatchQueue.main.async {
                        let img = UIImage(data: data as Data)
                        cell?.messageImageView.image = img
                        cell?.messageImageView.layer.cornerRadius = (cell?.messageImageView.frame.height)! / 2
                        cell?.messageImageView.clipsToBounds = true
                        self.cache.setObject(img!, forKey: indexPath.row as AnyObject)
                    }
                }
            }
        }
        return cell!
    }

    func getCompanyUsers(){
        companyUsers = CompanyUserMgr.sharedInstance.getAllCompanyUsers()
        filteredData =  companyUsers
        messageTableView.reloadData()
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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

