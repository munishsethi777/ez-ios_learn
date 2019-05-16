//
//  MyAchievements.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 29/11/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class
MyAchievements:UIViewController,UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet weak var myScoreTableView: UITableView!
    @IBOutlet weak var testTableView: UITableView!
    @IBOutlet weak var leaderboardTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var myScoreTableViewHeigh: NSLayoutConstraint!
    @IBOutlet weak var lpPickerView: UIPickerView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var noRowFoundLabel: UILabel!
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var leaderboardPicker: UIPickerView!
    @IBOutlet weak var badgeTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pointsBackView: UIView!
    @IBOutlet weak var scoreBackView: UIView!
    @IBOutlet weak var rankBackView: UIView!
    @IBOutlet weak var badgeTableView: UITableView!
    var loggedInUserSeq: Int = 0
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    var loggedInCompanySeq: Int = 0
    var badges = [Badge]()
    var badgesCount: Int = 0
    var progressHUD: ProgressHUD!
    var refreshControl:UIRefreshControl!
    var pickerData: [String] = [String]()
    var learningPlanPickerData: [String] = [String]()
    var profileAndModules = [Any]()
    var learningPlans = [Any]()
    var leaderBoardDataArr = [Any]()
    var myScoreDataArr = [Any]()
    var cache:NSCache<AnyObject, AnyObject>!
    override func viewDidLoad() {
        cache = NSCache()
        self.loggedInUserSeq =  PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        self.loggedInCompanySeq =  PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        badgeTableView.delegate = self
        badgeTableView.dataSource = self
        testTableView.delegate = self
        testTableView.dataSource = self
        progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        let progress = ProgressHUD(text:"Loading")
        progressView.addSubview(progress);
        getMyAchievements()
        getBadges()
       // setbackround()
        getProfileAndModules();
        getLearningPlans();
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshDashboard), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.pointsBackView.frame.size)
        gradient.colors = [UIColor.white.cgColor, UIColor.init(red: 110/255.0, green: 161/255.0, blue: 152/255.0, alpha: 1).cgColor]
        let shape = CAShapeLayer()
        shape.lineWidth = 4
        shape.path = UIBezierPath(rect: self.pointsBackView.bounds).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.pointsBackView.layer.addSublayer(gradient)
        
        let gradient2 = CAGradientLayer()
        gradient2.frame =  CGRect(origin: CGPoint.zero, size: self.scoreBackView.frame.size)
        gradient2.colors = [UIColor.white.cgColor, UIColor.init(red: 110/255.0, green: 161/255.0, blue: 152/255.0, alpha: 1).cgColor]
        let shape2 = CAShapeLayer()
        shape2.lineWidth = 4
        shape2.path = UIBezierPath(rect: self.scoreBackView.bounds).cgPath
        shape2.strokeColor = UIColor.black.cgColor
        shape2.fillColor = UIColor.clear.cgColor
        gradient2.mask = shape2
        self.scoreBackView.layer.addSublayer(gradient2)
        
        let gradient3 = CAGradientLayer()
        gradient3.frame =  CGRect(origin: CGPoint.zero, size: self.rankBackView.frame.size)
        gradient3.colors = [UIColor.white.cgColor, UIColor.init(red: 110/255.0, green: 161/255.0, blue: 152/255.0, alpha: 1).cgColor]
        let shape3 = CAShapeLayer()
        shape3.lineWidth = 4
        shape3.path = UIBezierPath(rect: self.rankBackView.bounds).cgPath
        shape3.strokeColor = UIColor.black.cgColor
        shape3.fillColor = UIColor.clear.cgColor
        gradient3.mask = shape3
        self.rankBackView.layer.addSublayer(gradient3)
        self.leaderboardPicker.delegate = self
        self.leaderboardPicker.dataSource = self
        lpPickerView.delegate = self
        lpPickerView.dataSource = self
        myScoreTableView.delegate = self
        myScoreTableView.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
  
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == leaderboardPicker){
            return pickerData.count
        }else{
            return learningPlanPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == leaderboardPicker){
            return pickerData[row]
        }else{
            return learningPlanPickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == leaderboardPicker){
            let profileAndModule = profileAndModules[row] as! [String:Any];
            let id = profileAndModule["id"] as! String
            getLeaderboardData(selectedId: id);
        }else{
            let learningPlans = self.learningPlans[row] as! [String:Any];
            let id = learningPlans["id"] as! String
            getMyScores(selectedId: id);
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Montserrat", size: 12)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        if(pickerView == leaderboardPicker){
            pickerLabel?.text = self.pickerData[row]
        }else{
            pickerLabel?.text = self.learningPlanPickerData[row]
        }
        return pickerLabel!;
    }
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.scrollView.backgroundColor = UIColor(patternImage: image)
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeNavBarColor()
    }
    
    func changeNavBarColor(){
        self.navigationController?.navigationBar.tintColor = .black
        let image = UIImage.imageFromColor(color: UIColor(red: 70/255.0, green: 110/255.0, blue: 165/255.0, alpha: 0.5))
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func refreshDashboard(refreshControl: UIRefreshControl) {
        getMyAchievements()
        getBadges()
        getProfileAndModules()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.badgeTableView){
            return self.badgesCount
        }else if(tableView == self.myScoreTableView){
            return self.myScoreDataArr.count
        }
        else{
            return self.leaderBoardDataArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == badgeTableView){
            let cellIdentifier = "BadgeTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BadgeTableViewCell
            let badge = badges[indexPath.row]
            cell?.badgeTitleLabel.text = badge.title
            cell?.badgeDetailImage.text = badge.detail
            cell?.badgeDateLabel.text = badge.date
            let imagePath = StringConstants.WEB_API_URL + badge.imagepath
            if let url = NSURL(string: imagePath) {
                if let data = NSData(contentsOf: url as URL) {
                    cell?.badgeImageView.image = UIImage(data: data as Data)
                }
            }
            return cell!
        }else if(tableView == myScoreTableView){
            let cellIdentifier = "MyScoreTableViewCell"
             let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyScoreTableViewCell
            var scoreData = myScoreDataArr[indexPath.row] as? [String : Any]
            if scoreData != nil{
                var moduleImage = scoreData!["moduleimage"] as? String
                let score = scoreData!["score"] as? String
                let moduleTitle = scoreData!["module"] as? String
                cell?.scoreLabelView.text = score
                cell?.moduleNameLableView.text = moduleTitle
                if(moduleImage == nil || moduleImage == ""){
                    moduleImage = "dummy.jpg"
                }
                if (self.cache.object(forKey: moduleTitle as AnyObject) != nil){
                    cell?.moduleImageView.image = self.cache.object(forKey: moduleTitle as AnyObject) as? UIImage
                    cell?.moduleImageView.layer.cornerRadius = (cell?.moduleImageView.frame.height)! / 2
                    cell?.moduleImageView.clipsToBounds = true
                }else {
                    moduleImage = StringConstants.IMAGE_URL + "modules/" + moduleImage!
                    if let url = NSURL(string: moduleImage!) {
                        DispatchQueue.global().async {
                            if let data = NSData(contentsOf: url as URL) {
                                DispatchQueue.main.async {
                                    let img = UIImage(data: data as Data)
                                    cell?.moduleImageView.image = UIImage(data: data as Data)
                                    cell?.moduleImageView.layer.cornerRadius = (cell?.moduleImageView.frame.height)! / 2
                                    cell?.moduleImageView.clipsToBounds = true
                                    self.cache.setObject(img!, forKey: moduleTitle as AnyObject)
                                }
                            }
                        }
                    }
                }
            }
            return cell!
        }
        else{
            let cellIdentifier = "LeaderboardTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LeaderboardTableViewCell
            let leaderboardData = leaderBoardDataArr[indexPath.row] as? [String : Any]
            if(leaderboardData != nil){
                var userImage = leaderboardData!["imagepath"] as? String
                var userName = leaderboardData!["uname"] as? String
                if(userName != nil && userName != "" && userName != "null"){
                }else{
                    userName = leaderboardData!["username"] as? String;
                }
                let totalScore = leaderboardData!["totalscore"] as? String
                cell?.userNameLabel.text = userName
                cell?.scoreLabel.text = totalScore
                if(userImage == nil){
                    userImage = "dummy.jpg"
                }
                if (self.cache.object(forKey: userName as AnyObject) != nil){
                    cell?.userImageView?.image = self.cache.object(forKey: userName as AnyObject) as? UIImage
                    cell?.userImageView.layer.cornerRadius = (cell?.userImageView.frame.height)! / 2
                    cell?.userImageView.clipsToBounds = true
                }else {
                    userImage = StringConstants.WEB_API_URL + userImage!
                    if let url = NSURL(string: userImage!) {
                        DispatchQueue.global().async {
                            if let data = NSData(contentsOf: url as URL) {
                                DispatchQueue.main.async {
                                    let img = UIImage(data: data as Data)
                                    cell?.userImageView.image = UIImage(data: data as Data)
                                    cell?.userImageView.layer.cornerRadius = (cell?.userImageView.frame.height)! / 2
                                    cell?.userImageView.clipsToBounds = true
                                    self.cache.setObject(img!, forKey: userName as AnyObject)
                                }
                            }
                        }
                    }
                }
            }
            return cell!
        }
    }
    
    func getProfileAndModules(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_PROFILE_AND_MODULES, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.populateProfileAndModule(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func getLearningPlans(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_ALL_LEARNING_PLANS, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.populateLearningPlans(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func populateLearningPlans(response : [String: Any]){
        learningPlans = response["learningplans"] as! [Any]
        for i in 0..<learningPlans.count{
            let lpJson = learningPlans[i] as! [String:Any]
            let name = lpJson["title"] as! String
            learningPlanPickerData.append(name);
        }
        lpPickerView.reloadAllComponents()
        lpPickerView.selectRow(0, inComponent: 0, animated: true)
        let lp = learningPlans[0] as! [String:Any];
        let id = lp["id"] as! String
        getMyScores(selectedId: id);
    }
    
    func populateProfileAndModule(response : [String: Any]){
        profileAndModules = response["profilesAndModules"] as! [Any]
        for i in 0..<profileAndModules.count{
            let profileAndModulesJson = profileAndModules[i] as! [String:Any]
            let name = profileAndModulesJson["name"] as! String
            pickerData.append(name);
        }
        leaderboardPicker.reloadAllComponents()
        leaderboardPicker.selectRow(0, inComponent: 0, animated: true)
        let profileAndModule = profileAndModules[0] as! [String:Any];
        let id = profileAndModule["id"] as! String
        getLeaderboardData(selectedId: id);
    }
    
    func getMyAchievements(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_ACHIEVEMENTS, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadAchievementData(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func getLeaderboardData(selectedId:String){
        progressView.isHidden = false
        let selectedIdArr = selectedId.split(separator: "_")
        let prefix = selectedIdArr[0]
        let id = selectedIdArr[1];
        var actionUrl =  StringConstants.GET_LEADERBOARD_BY_PROFILE;
        if(prefix == "module"){
            actionUrl = StringConstants.GET_LEADERBOARD_BY_MODULE;
        }else if(prefix == "lp"){
            actionUrl = StringConstants.GET_LEADERBOARD_BY_LEARNINGPLAN;
        }
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,id]
        let apiUrl: String = MessageFormat.format(pattern: actionUrl, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadLeaderboard(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    func getMyScores(selectedId:String){
        progressView.isHidden = false
        let id = selectedId
        let actionUrl =  StringConstants.GET_SCORES;
        let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,id]
        let apiUrl: String = MessageFormat.format(pattern: actionUrl, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadMyScore(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func loadMyScore(response:[String: Any]){
        myScoreDataArr = response["scores"] as! [Any]
        progressView.isHidden = true
        myScoreTableView.reloadData()
        
        myScoreTableView.frame.size.height = CGFloat(myScoreDataArr.count*100)
        myScoreTableViewHeigh.constant = CGFloat(myScoreDataArr.count*100)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height:badgeTableView.frame.size.height + leaderboardTableViewHeight.constant + myScoreTableViewHeigh.constant+600)
        
    }
    
    func loadLeaderboard(response:[String: Any]){
        leaderBoardDataArr = response["leaderboarddata"] as! [Any]
        if(leaderBoardDataArr.count == 0){
            self.testTableView.isHidden = true
            self.noRowFoundLabel.isHidden = false
        }else{
           self.noRowFoundLabel.isHidden = true
           self.testTableView.isHidden = false
           self.testTableView.reloadData()
        }
        progressView.isHidden = true
        testTableView.frame.size.height = CGFloat(leaderBoardDataArr.count * 80)
        leaderboardTableViewHeight.constant = CGFloat(leaderBoardDataArr.count * 80)
        
        //badgeTableView.frame.size.height = CGFloat(badgesCount*100)
        //badgeTableViewHeight.constant = CGFloat(badgesCount*100)
        
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height:badgeTableView.frame.size.height + 600 + myScoreTableViewHeigh.constant + leaderboardTableViewHeight.constant)
    }

    
    
    func getBadges(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_ACHIEVEMENT_BADGES, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadBadges(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func loadAchievementData(response: [String: Any]){
        let responseJson = response["dashboardData"] as! [String:Any]
        let totalScore = responseJson["totalScores"] as! Int
        var userRankStr = responseJson["userRank"] as? Int
        if(userRankStr == nil){
            userRankStr = 0
        }
        let trainings = responseJson["pendingTrainings"] as! [String: Any]
        let maxScore = trainings["maxScore"] as! Int
        let points = responseJson["points"] as! Int
        let totalScoreStr = String(totalScore) + "/" + String(maxScore)
        rankLabel.text = String(userRankStr!)
        pointsLabel.text = String(points)
        scoreLabel.text = totalScoreStr
    }
    
    func loadBadges(response: [String: Any]){
        let badgesJsonArr = response["badges"] as! [Any]
        badgesCount = badgesJsonArr.count
        for i in 0..<badgesJsonArr.count{
            let badgeJson = badgesJsonArr[i] as! [String:Any]
            let title = badgeJson["title"] as! String
            let detail = badgeJson["detail"] as! String
            let date = badgeJson["date"] as! String
            let imagePath = badgeJson["imagepath"] as! String
            let badge = Badge(title: title, detail: detail, date: date, imagepath: imagePath)
            badges.append(badge)
        }
        progressHUD.hide()
        badgeTableView.reloadData()
        badgeTableView.frame.size.height = CGFloat(badgesCount*100)
        badgeTableViewHeight.constant = CGFloat(badgesCount*100)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height:badgeTableView.frame.size.height + 400)
        if #available(iOS 10.0, *){
            refreshControl.endRefreshing()
        }
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


