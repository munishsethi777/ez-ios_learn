//
//  LearningPlanViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 23/01/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class LearningPlanViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,IndicatorInfoProvider{
    
    
    var  progressHUD: ProgressHUD!
    var loggedInUserSeq:Int!
    var loggedInCompanySeq:Int!
    var learningPlanArr:[Any]!
    var selectedlearningPlanSeq:Int!
    var cache:NSCache<AnyObject, AnyObject>!
    
   
    @IBOutlet weak var lpTableView: UITableView!
    var refreshControl:UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        cache = NSCache()
        learningPlanArr = []
        lpTableView.dataSource  = self
        lpTableView.delegate = self
        //setbackround()
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        getLearningPlans()
        progressHUD = ProgressHUD(text: "Loading")
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
            lpTableView.refreshControl = refreshControl
        }
        self.view.addSubview(progressHUD)
    }
    var itemInfo: IndicatorInfo = "LearningPlans"
    
    

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    @objc func refreshView(control:UIRefreshControl){
        cache = NSCache()
        getLearningPlans()
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
    override func viewWillDisappear(_ animated: Bool) {
       changeNavBarColor()
    }
    func setbackround(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login_back_bw_lighter.jpg")?.draw(in: self.view.bounds)
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.lpTableView.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return learningPlanArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "LearningPlanTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LearningPlanTableViewCell
        let learningPlan = learningPlanArr[indexPath.row] as! [String: Any]
        let id = learningPlan["id"] as! String
        let completedModulesCount = learningPlan["completedModulesCount"] as! Int
        let points = learningPlan["points"] as! Int
        let score = learningPlan["score"] as! Int
        let badges = learningPlan["badges"] as? [Any]
        let moduleArr = learningPlan["modules"] as! [Any]
        cell?.bottomView.gradientColor = [UIColor.white.cgColor, UIColor.init(red: 99/255.0, green: 144/255.0, blue: 198/255.0, alpha: 1).cgColor]
        var moduleImageUrl : String?
        if moduleArr.count > 0 {
            let moduleJson = moduleArr[0] as! [String: Any]
            moduleImageUrl = moduleJson["imagepath"] as? String
        }
        if(moduleImageUrl == nil || (moduleImageUrl?.isEmpty)!){
            moduleImageUrl = "dummy.jpg"
        }
            var continueLabelText = "Continue"
            cell?.titleLabel.text = learningPlan["title"] as? String
            cell?.desLabel.text = learningPlan["description"] as? String
            let percent = learningPlan["percentCompleted"] as! Float
            
            let totalModule = moduleArr.count
            
            if(Int(percent) > 0){
                cell?.progress.progress = percent / 100
            }
            if (self.cache.object(forKey: id as AnyObject) != nil){
                cell?.lpImageView?.image = self.cache.object(forKey: id as AnyObject) as? UIImage
                cell?.lpImageView.layer.cornerRadius = (cell?.lpImageView.frame.height)! / 2
                cell?.lpImageView.clipsToBounds = true
            }else {
                moduleImageUrl = StringConstants.IMAGE_URL + "modules/" + moduleImageUrl!
                if let url = NSURL(string: moduleImageUrl!) {
                    DispatchQueue.global().async {
                        if let data = NSData(contentsOf: url as URL) {
                            DispatchQueue.main.async {
                                let img = UIImage(data: data as Data)
                                cell?.lpImageView.image = UIImage(data: data as Data)
                                cell?.lpImageView.layer.cornerRadius = (cell?.lpImageView.frame.height)! / 2
                                cell?.lpImageView.clipsToBounds = true
                                self.cache.setObject(img!, forKey: id as AnyObject)
                            }
                        }
                    }
                }
                
            }
            cell?.scoreLabel.isHidden = true
            cell?.pointLabel.isHidden = true
            cell?.scoreValueLabel.isHidden = true
            cell?.pointValueLabel.isHidden = true
            cell?.percentLabel.text = String(Int(percent)) + "%"
            cell?.launchPlanImageView.image = UIImage(named: "arrow_green.png")
            cell?.bottomView.gradientColor = [UIColor.white.cgColor, UIColor.init(red: 110/255.0, green: 143/255.0, blue: 130/255.0, alpha: 1).cgColor]
            if(completedModulesCount == 0){
                cell?.bottomView.gradientColor = [UIColor.white.cgColor, UIColor.init(red: 99/255.0, green: 144/255.0, blue: 198/255.0, alpha: 1).cgColor]
                continueLabelText = "Launch"
                cell?.desLabel.isHidden = false
                cell?.launchPlanImageView.image = UIImage(named: "arrow_up.png")
            }else if(completedModulesCount == totalModule){
                continueLabelText = "Review"
                cell?.bottomView.gradientColor = [UIColor.white.cgColor, UIColor.init(red: 231/255.0, green: 124/255.0, blue: 34/255.0, alpha: 1).cgColor]
                cell?.launchPlanImageView.image = UIImage(named: "arrow_orange.png")
                let dateOfPlay = learningPlan["dateofplay"] as! String
                let date = DateUtil.sharedInstance.stringToDate(dateStr: dateOfPlay)
                cell?.percentLabel.text = DateUtil.sharedInstance.dateToString(date: date, format: DateUtil.format2)
                cell?.scoreValueLabel.text = String(score)
                cell?.pointValueLabel.text = String(points)
                cell?.moduleCountLabel.isHidden = true
                cell?.scoreLabel.isHidden = false
                cell?.pointLabel.isHidden = false
                cell?.scoreValueLabel.isHidden = false
                cell?.pointValueLabel.isHidden = false
                cell?.desLabel.isHidden = true
            }
            if (completedModulesCount == 0 || completedModulesCount < totalModule){
                cell?.moduleCountLabel.isHidden = false
                var completedText = String(totalModule) + " Module"
                if(totalModule > 1){
                    completedText = completedText + "s"
                }
                if(completedModulesCount > 0){
                    completedText = String(completedModulesCount) + "/" + completedText
                }
                cell?.moduleCountLabel.text = completedText
            }
            cell?.continueLabel.text = continueLabelText
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
                                if let img = UIImage(data: data as Data){
                                    imageView.image = UIImage(data: data as Data)
                                    self.cache.setObject(img, forKey: badgeSeq as AnyObject)
                                }
                            }
                        }
                    }
                    imageView.tag = 5
                    cell?.contentView.addSubview(imageView)
                    x = x + 25
                }
            }
        let tap = UITapGestureRecognizer(target: self, action: #selector(launch))
        cell?.launchPlanImageView.tag = Int(id)!
        cell?.launchPlanImageView.addGestureRecognizer(tap)
        cell?.launchPlanImageView.isUserInteractionEnabled = true
        cell?.progressView.sendSubview(toBack: (cell?.bottomView)!)
        cell?.bottomView.layer.borderWidth = 0.3
        cell?.bottomView.layer.borderColor = UIColor.lightGray.cgColor
        cell?.bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        cell?.bottomView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell?.bottomView.layer.shadowOpacity = 0.5
        cell?.bottomView.layer.shadowRadius = 4.0
        cell?.bottomView.commonInit()
        return cell!
    }
    
    
    @objc func launch(sender:UITapGestureRecognizer){
        selectedlearningPlanSeq = sender.view?.tag
        self.performSegue(withIdentifier: "LearningPlanDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func getLearningPlans(){
        let args: [Int] = [self.loggedInUserSeq,self.loggedInCompanySeq]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_LEARNING_PLAN_DETAIL, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.loadLearningPlans(response: json)
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
    
    func loadLearningPlans(response: [String: Any]){
        learningPlanArr = response["learningPlanDetails"] as! [Any]
        if #available(iOS 10.0, *) {
            self.refreshControl.endRefreshing()
        }
        lpTableView.reloadData()
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondController = segue.destination as? TrainingViewController {
            secondController.selectedLpSeq = selectedlearningPlanSeq
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo;
    }
}
