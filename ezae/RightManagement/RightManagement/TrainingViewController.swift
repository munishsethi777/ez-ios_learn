//
//  TrainingViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 02/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
import Foundation
class TrainingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    var loggedInUserSeq: Int = 0
    var loggedInCompanySeq: Int = 0
    var lpDetailCount: Int = 0
    var lpModuleArr: [[String]] = []
    var lpDetailArr: [Any] = []
    var headerCount = 0;
    var selectedModuleSeq: Int = 0
    var selectedLpSeq: Int = 0
    var refreshControl:UIRefreshControl!
    var  progressHUD: ProgressHUD!
    var totalModuleCount:Int = 0
    var learningPlanJson:[String: Any] = [:]
    var cell:TrainingTableViewCell!
    
    
    var cache:NSCache<AnyObject, AnyObject>!
    @IBOutlet weak var trainingTableView: UITableView!
    override func viewDidLoad() {
       super.viewDidLoad()
       cache = NSCache()
       trainingTableView.delegate = self
       trainingTableView.dataSource = self
       //setbackround()
       self.loggedInUserSeq =  PreferencesUtil.sharedInstance.getLoggedInUserSeq()
       self.loggedInCompanySeq =  PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
         NotificationCenter.default.addObserver(self, selector: #selector(TrainingViewController.refreshController), name: NSNotification.Name(rawValue: "refreshController"), object: nil)
        progressHUD = ProgressHUD(text: "Loading")
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
            trainingTableView.refreshControl = refreshControl
        }
       self.view.addSubview(progressHUD)
       getLearningPlanAndModules()
    }
    
    @objc func refreshController(){
        cache = NSCache()
        totalModuleCount = 0
        headerCount = 0
        getLearningPlanAndModules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavBarColor()
    }
    
    func changeNavBarColor(){
        self.navigationController?.navigationBar.tintColor = .black
        let image = UIImage.imageFromColor(color: UIColor(red: 110/255.0, green: 143/255.0, blue: 130/255.0, alpha: 0.5))
        self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        //self.navigationController?.navigationBar.isTranslucent = true
    }
   
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.trainingTableView.backgroundColor = UIColor(patternImage: image)
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
    
    @objc func refreshView(refreshControl: UIRefreshControl) {
        refreshController()
    }
    
    func backAction(){
        //print("Back Button Clicked")
        dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  totalModuleCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerCount
    }
  
    
    var isReattempted:Bool = false;
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row: Int = indexPath.row
        let section: Int = indexPath.section
        let lpJsonArr = learningPlanJson //lpDetailArr[section] as! [String: Any]
        let moduleJsonArr = learningPlanJson["modules"] as! [Any]
        let moduleJson = moduleJsonArr[row] as! [String: Any]
        let moduleSeq = moduleJson["seq"] as! String
        let cellIdentifier = "TrainingTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TrainingTableViewCell
        var moduleImageUrl = moduleJson["imagepath"] as? String
        var lpSeqStr = moduleJson["learningPlanSeq"] as? String
        var seqStr = moduleJson["seq"] as? String
        if(lpSeqStr == nil){
            lpSeqStr = "0"
        }
        if(seqStr == nil){
            seqStr = "0"
        }
        var lpSeq = Int(lpSeqStr!)!
        var seq = Int(seqStr!)!
        var progressStr = moduleJson["progress"] as? String
        var moduleType = moduleJson["moduletype"] as! String
        var leaderboardRankStr = moduleJson["leaderboard"] as? String
        let reattempted = moduleJson["reattempts"] as! Int
        let badges = moduleJson["badges"] as? [Any]
        if(leaderboardRankStr == nil){
            leaderboardRankStr = "0"
        }
        let rank: Int = Int(leaderboardRankStr!)!
        if(progressStr == nil){
            progressStr = "0"
        }
        let progress: Int = Int(progressStr!)!
        if(moduleImageUrl == nil || (moduleImageUrl?.isEmpty)!){
            moduleImageUrl = "dummy.jpg"
        }
        
        if (self.cache.object(forKey: moduleSeq as AnyObject) != nil){
            cell?.moduleImageView?.image = self.cache.object(forKey: moduleSeq as AnyObject) as? UIImage
            cell?.moduleImageView.layer.cornerRadius = (cell?.moduleImageView.frame.height)! / 2
            cell?.moduleImageView.clipsToBounds = true
        }else {
            moduleImageUrl = StringConstants.IMAGE_URL + "modules/" + moduleImageUrl!
//            if let url = NSURL(string: moduleImageUrl!) {
//                if let data = NSData(contentsOf: url as URL) {
//                    let img = UIImage(data: data as Data)
//                    cell?.moduleImageView.image = img
//                    cell?.moduleImageView.layer.cornerRadius = (cell?.moduleImageView.frame.height)! / 2
//                    cell?.moduleImageView.clipsToBounds = true
//                    self.cache.setObject(img!, forKey: moduleSeq as AnyObject)
//                }
//            }
            if let url = NSURL(string: moduleImageUrl!) {
                DispatchQueue.global().async {
                    if let data = NSData(contentsOf: url as URL) {
                        DispatchQueue.main.async {
                             let img = UIImage(data: data as Data)
                                cell?.moduleImageView.image = img
                                cell?.moduleImageView.layer.cornerRadius = (cell?.moduleImageView.frame.height)! / 2
                                cell?.moduleImageView.clipsToBounds = true
                                self.cache.setObject(img!, forKey: moduleSeq as AnyObject)
                            //}
                        }
                    }
                }
            }
        }
        cell?.moduleTitle.text = moduleJson["title"] as? String
        var points = moduleJson["points"] as? String
        if(points == nil){
            points = "0"
        }
        var score = moduleJson["score"] as? String
        if(score == nil){
            score = "0"
        }
        cell?.pointLabel.text = points
        cell?.scoreLabel.text = score
        var buttonTitle: String = "Launch"
        cell?.launchImageButton.setImage(UIImage(named: "arrow_up.png"), for: .normal)
        cell?.baseView.gradientColor = [UIColor.white.cgColor, UIColor.init(red: 99/255.0, green: 144/255.0, blue: 198/255.0, alpha: 1).cgColor]
        let isLocalProgressExists:Bool = ModuleProgressMgr.sharedInstance.isProgressForModule(moduleSeq: seq, learningPlanSeq: lpSeq)
        if(progress < 100 && isLocalProgressExists){
            buttonTitle = "Continue"
            cell?.baseView.gradientColor = [UIColor.white.cgColor, UIColor.init(red: 110/255.0, green: 143/255.0, blue: 130/255.0, alpha: 1).cgColor]
            cell?.launchImageButton.setImage(UIImage(named: "arrow_green.png"), for: .normal)
        }
        isReattempted = false;
        if(progress == 100){
            cell?.launchImageButton.isHidden = false
            cell?.baseView.gradientColor = [UIColor.white.cgColor, UIColor.init(red: 231/255.0, green: 124/255.0, blue: 34/255.0, alpha: 1).cgColor]
            if(reattempted > 0){
                buttonTitle = "Re-attempt"
                cell?.launchImageButton.setImage(UIImage(named: "reattempt1.png"), for: .normal)
                isReattempted = true
            }else{
                buttonTitle = "Review"
                cell?.launchImageButton.setImage(UIImage(named: "arrow_orange.png"), for: .normal)
                if(moduleType == "elearning"){
                    buttonTitle = "Completed"
                    cell?.launchImageButton.isEnabled = false
                    cell?.launchModuleButton.isEnabled = false
                }
            }
            
        }else{
            cell?.launchImageButton.isHidden = false
        }
        let isLockSequence = lpJsonArr["lockSequence"] as! Bool;
        cell?.launchModuleButton.isEnabled = true
        cell?.launchImageButton.isEnabled = true
        if(row > 0 && isLockSequence){
            let previousModuleJson = moduleJsonArr[row-1] as! [String: Any]
            let lastProgressStr = previousModuleJson["progress"] as? String
            var lastProgress = 0;
            if(lastProgressStr != nil){
                lastProgress =  Int(lastProgressStr!)!
            }
            if(lastProgress < 100){
                cell?.launchModuleButton.isEnabled = false
                cell?.launchImageButton.isEnabled = false
            }
        }
        cell?.launchModuleButton.setTitle(buttonTitle, for: .normal)
        cell?.launchModuleButton.tag = seq
    
        cell?.launchModuleButton.addTarget(self, action:#selector(launchModule), for: .touchUpInside)
        
        cell?.launchImageButton.tag = seq
        cell?.launchImageButton.titleLabel?.tag = lpSeq
        cell?.launchImageButton.addTarget(self, action:#selector(launchModule), for: .touchUpInside)
       
        cell?.scoreLabel.isHidden = true
        cell?.pointLabel.isHidden = true
        cell?.scoreCaptionLabel.isHidden = true
        cell?.pointsCaptionLabel.isHidden = true
        if(moduleType == "quiz" && progress == 100){
            if(rank > 0){
                cell?.leaderboardLabel.text = String(rank) + "\nLeaderboard"
            }
            cell?.scoreLabel.text = score
            cell?.pointLabel.text = points
            cell?.scoreLabel.isHidden = false
            cell?.pointLabel.isHidden = false
            cell?.scoreCaptionLabel.isHidden = false
            cell?.pointsCaptionLabel.isHidden = false
        }else{
            cell?.leaderboardLabel.isHidden = true
        }
        let theSubviews: Array = (cell?.contentView.subviews)!
        for view in theSubviews{
            if(view.tag == 5){
                view.removeFromSuperview()
            }
        }
        
        if(badges != nil){
            var  x = 165
            for var i in 0..<badges!.count{
                let imageView = UIImageView.init()
                imageView.frame = CGRect(x:x,y:55,width:22,height:22)
                let badgesJson = badges![i] as! [String: Any]
                let badgeSeq = badgesJson["seq"] as! String
                let imagePath = badgesJson["imagepath"] as! String
                if (self.cache.object(forKey: badgeSeq as AnyObject) != nil){
                    imageView.image = self.cache.object(forKey: badgeSeq as AnyObject) as? UIImage
                }else{
                    let imageUrl = StringConstants.WEB_API_URL + imagePath
                    if let url = NSURL(string: imageUrl) {
                        if let data = NSData(contentsOf: url as URL) {
                            let img = UIImage(data: data as Data)
                            imageView.image = UIImage(data: data as Data)
                            self.cache.setObject(img!, forKey: badgeSeq as AnyObject)
                        }
                    }
                }
                imageView.tag = 5
                cell?.contentView.addSubview(imageView)
                x = x + 15
            }
        }
        cell?.contentView.sendSubview(toBack:(cell?.baseView)!)
        cell?.baseView.layer.borderWidth = 0.3
        cell?.baseView.layer.borderColor = UIColor.lightGray.cgColor
        cell?.baseView.layer.shadowColor = UIColor.lightGray.cgColor
        cell?.baseView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell?.baseView.layer.shadowOpacity = 0.5
        cell?.baseView.layer.shadowRadius = 4.0
        cell?.baseView.commonInit()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)->String?{
        let sectionHeader = learningPlanJson["title"] as? String
        return sectionHeader
    }
    
    @objc func launchModule(sender:UIButton){
//        selectedModuleSeq = sender.tag
//        selectedLpSeq = (sender.titleLabel?.tag)!
//        self.performSegue(withIdentifier: "LaunchModuleController", sender: nil)
        
        let launchModuleVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaunchModule") as! LaunchModuleViewController
        launchModuleVC.moduleSeq = sender.tag
        launchModuleVC.lpSeq = (sender.titleLabel?.tag)!
        if(isReattempted){
            let reattemptedAlert = UIAlertController(title: "Re-attempted", message: "Do you really want to re-attempt this Training?", preferredStyle: UIAlertControllerStyle.alert)
            reattemptedAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                launchModuleVC.isReattempt = self.isReattempted
                self.present(launchModuleVC, animated: true, completion: nil)
            }))
            reattemptedAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            present(reattemptedAlert, animated: true, completion: nil)
        }else{
          
            self.present(launchModuleVC, animated: true, completion: nil)
        }
    }
    
    var headerArr:[Int:UIView] = [:]
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(headerArr[section] != nil){
            return headerArr[section]!
        }
        let headerView =  UIView.init(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        //headerView.backgroundColor = UIColor.lightGray
        headerView.backgroundColor = UIColor(red: 110/255, green: 143/255, blue: 130/255, alpha: 1)
        
        let lpJsonArr = learningPlanJson
        let percentCompleted = lpJsonArr["percentCompleted"] as! CGFloat
        let modulesJsonArr = lpJsonArr["modules"] as! [Any]
        let progress = UICircularProgressRingView.init(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
        progress.setProgress(value: CGFloat(percentCompleted), animationDuration: 2)
        progress.innerRingColor = UIColor(red: 171/255, green: 64/255, blue: 75/255, alpha: 1)
        
        progress.outerRingColor = UIColor.white
        progress.innerRingWidth = 4
        progress.outerRingWidth = 5
        progress.font = UIFont(name: "Helvetica Neue", size: 10)!
        progress.fontColor = UIColor.white
        progress.viewStyle = 5
        for subview in headerView.subviews {
            if subview is UICircularProgressRingView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        headerView.addSubview(progress)
        let label = UILabel.init(frame: CGRect(x: 50, y: 35, width: 80, height: 10))
        label.text = String(modulesJsonArr.count) + " Modules"
        label.font = UIFont(name: "Helvetica Neue", size: 10)
        label.textColor = UIColor.white
        headerView.addSubview(label)
        
        let sectionHeader = lpJsonArr["title"] as? String
        let headerLabel = UILabel.init(frame: CGRect(x: 50, y: 10, width: self.view.frame.width, height: 16))
        headerLabel.text = sectionHeader
        headerLabel.font = UIFont(name: "Helvetica Neue", size: 16)
        headerLabel.textColor = UIColor.white
        headerView.addSubview(headerLabel)
        headerArr[section] = headerView
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func getLearningPlanAndModules(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq,selectedLpSeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_LEARNING_PLAN_MODULES, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadLearningPlanAndModule(jsonReponse: json)
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
    
    func loadLearningPlanAndModule(jsonReponse:[String:Any]){
        learningPlanJson = jsonReponse["learningPlanDetails"] as! [String:Any]
        headerCount = 1;
        lpDetailArr = []
        lpModuleArr = []
        lpDetailCount = 0
        trainingTableView.reloadData()
        totalModuleCount = 0
        var jsonArr: [String] = []
        let lpDetailJson = learningPlanJson
        let percentCompleted = lpDetailJson["percentCompleted"] as? Int
        let title = lpDetailJson["title"] as! String
        jsonArr.append(title)
        let modulesJsonArr = lpDetailJson["modules"] as! [Any]
        for var j in 0..<modulesJsonArr.count{
             let moduleJson = modulesJsonArr[j] as! [String: Any]
             let moduleTile = moduleJson["title"] as! String
             jsonArr.append(moduleTile)
        }
        lpModuleArr.append(jsonArr)
        totalModuleCount =  modulesJsonArr.count
        if #available(iOS 10.0, *) {
            self.refreshControl.endRefreshing()
        }
        progressHUD.hide()
        trainingTableView.reloadData()
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondController = segue.destination as? LaunchModuleViewController {
           secondController.moduleSeq = selectedModuleSeq
           secondController.lpSeq = selectedLpSeq
        }
    }
    
    
    
    
    
}
