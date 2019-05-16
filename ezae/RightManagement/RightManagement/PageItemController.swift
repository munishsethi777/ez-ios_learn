//
//  PageItemController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 08/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit
import CoreData
class PageItemController: UIViewController, SSRadioButtonControllerDelegate,UITableViewDataSource, UITableViewDelegate,UIWebViewDelegate{
    
    
    func didSelectButton(selectedButton: UIButton?) {
    }
    var radioButtonController: SSRadioButtonsController?
   
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var feebackErrorLabel: UILabel!
    @IBOutlet weak var feedbackSuccessLabel: UILabel!
    @IBOutlet weak var submitProgress: UIButton!
    @IBOutlet weak var quesTitle: UILabel!
    var itemIndex: Int = 0 // ***
    var questionTitleText: String = ""
    var moduleJson: [String: Any] = [:]
    var questionJson: [String: Any] = [:]
    var imageName: String = ""
    var moduleType:String =  ""
    var questionType: String = ""
    var options: [Any] = []
    var pageNo: Int = 0
    var parentController: LaunchModuleViewController!
    var loggedInUserSeq:Int = 0
    var loggedInCompanySeq: Int = 0
    var totalQuestion: Int = 0
    var selectedAnsSeqs:[Int] = []
    var longQuestionTextView:UITextView!
    var switcher: UISwitch!
    var activityData:[String: Any] = [:]
    var moduleProgress:[Any] = []
    var isProgressExist = false
    var isActivitySaved:Bool = false
    var feedback_success_arr:[String]!
    var feedback_error_arr:[String]!
    var isShowFeedback:Bool = false
    var seqOptions:[Any] = []
    var sliderLabel:UILabel!
    @IBAction func submitProgressAction(_ sender: UIButton) {
        submit(question:questionJson,isTimeUp: false)
    }
    
    @IBOutlet weak var scrolView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedAnsSeqs = []
        feedback_success_arr = []
        feedback_error_arr = []
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq();
        moduleType = moduleJson["moduletype"] as! String
        scrolView.layoutIfNeeded()
        scrolView.isScrollEnabled = true
        scrolView.contentSize = CGSize(width: self.view.frame.width, height: scrolView.frame.size.height)
        if(moduleType != "elearning"){
            let questionTitle = questionJson["title"] as! String
            quesTitle.text = String(pageNo) + ". " + questionTitle
            quesTitle.numberOfLines = 3
            questionType = questionJson["type"] as! String;
            options = questionJson["answers"] as! [Any];
            seqOptions = options
            
            moduleProgress = questionJson["progress"] as! [Any]
            let showFeedback = moduleJson["isshowfeedback"] as! String
            isShowFeedback =  Int(showFeedback)! > 0
            if(!moduleProgress.isEmpty){
                isProgressExist = true
            }
            handleWithExistingProgress()
            let allQuestions = moduleJson["questions"] as! [Any]
            
            totalQuestion = allQuestions.count
       
            if(questionType == StringConstants.SINGLE_TYPE_QUESTION){
                addRadioViews()
            }else if(questionType == StringConstants.MULTI_TYPE_QUESTION){
                addCheckboxViews()
            }else if(questionType == StringConstants.LONG_TYPE_QUESTION){
                addTextView()
            }else if(questionType == StringConstants.YES_NO_TYPE_QUESTION){
                addSwitchView()
            }else if(questionType == StringConstants.WEB_PAGE_TYPE_QUESTION){
                addWebView()
            }else if(questionType == StringConstants.MEDIA_TYPE_QUESTION){
                addWebViewForVideo()
            }
            else if(questionType == StringConstants.DOC_TYPE_QUESTION){
                addWebViewforDoc()
            }else if(questionType == StringConstants.LIKART_SCALE_TYPE_QUESTION){
                addRadioViews()
            }else if(questionType == StringConstants.SEQUENCING){
                addTableView()
            }else if(questionType == StringConstants.ESTIMATE_PERCENT_TYPE_QUESTION){
                addSliderView()
            }
        }else{
            addElearningWebView();
        }
        executeSaveActivityCall()
        if(!moduleProgress.isEmpty){
            handleViews()
        }
        
    }
    
    func handleWithExistingProgress(){
        let questionSeq = Int(questionJson["seq"] as! String)!
        let moduleSeq = Int(questionJson["moduleSeq"] as! String)!
        let learningPlanseq = Int(questionJson["learningPlanSeq"] as! String)!
        let existingProgress = ModuleProgressMgr.sharedInstance.getExistingProgressArray(questionSeq: questionSeq, moduleSeq: moduleSeq, learningPlanSeq: learningPlanseq)
        moduleProgress = existingProgress + moduleProgress
        handleViews()
    }
    
    @IBAction func clickOnButton(_ sender: Any) {
        goToNextPage()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: { () -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshController"), object: nil)
        })
    }
    private func goToNextPage(){
        if(isLastPage()){
            //self.performSegue(withIdentifier: "showTrainingTabs", sender: self)
            //dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: { () -> Void in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshController"), object: nil)
            })
        }else{
            parentController.goNextPage(index:itemIndex+1)
        }
    }
    
    private func isLastPage()->Bool{
        return itemIndex+1 == totalQuestion
    }
    
    func addRadioViews(){
        var y:CGFloat = quesTitle.frame.height + 10
        var button: SSRadioButton!
        radioButtonController = SSRadioButtonsController()
        var existingAnswerSeq:String = ""
        if(!moduleProgress.isEmpty){
            let existingProgress = moduleProgress[0] as? [String: Any]
            existingAnswerSeq = existingProgress?["answerSeq"] as! String
            selectedAnsSeqs.append(Int(existingAnswerSeq)!)
        }
        for i in 0..<options.count{
            let option = options[i] as! [String: Any]
            let title = option["title"] as! String
            let seq = option["seq"] as! String
            button = SSRadioButton(type: .system)
            button.frame = CGRect(x:20,y:y,width:super.view.frame.width-40,height:35)
            y = y + 35
            button.circleRadius = CGFloat(8)
            button.circleColor = UIColor.black
            button.setTitle(title, for: .normal)
            button.tintColor = UIColor.darkGray
            button.tag = Int(seq)!
            button.addTarget(self, action:#selector(addSelectedAnsSeq), for: .touchUpInside)
            if(seq == existingAnswerSeq){
                button.isSelected = true
            }
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            button.titleLabel?.font = UIFont(name:quesTitle.font.fontName, size: 11.00)
            button.titleLabel?.numberOfLines = 2
            view.addSubview(button)
            
            radioButtonController?.addButton(button)
            radioButtonController?.delegate = self
            radioButtonController?.shouldLetDeSelect = true
        }
        if(!moduleProgress.isEmpty){
            getScoreForSelectedOption()
        }
    }
    func addCheckboxViews(){
        var y:CGFloat = quesTitle.frame.height + 10.00
        var button: CheckBox!
        for i in 0..<options.count{
            let option = options[i] as! [String: Any]
            let title = option["title"] as! String
            let seq = option["seq"] as! String
            button = CheckBox(type: .system)
            button.awakeFromNib()
            button.tintColor = UIColor.darkGray
            button.titleEdgeInsets.left = 0
            button.tag = Int(seq)!
            button.frame = CGRect(x:20,y:y,width:super.view.frame.width-40,height:35)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            button.titleLabel?.font = UIFont(name:quesTitle.font.fontName, size: 11.00)
            button.titleLabel?.numberOfLines = 2
            
            let isChecked = isOptionSeqExistsInAnwers(optionSeq: seq)
            if(isChecked){
                selectedAnsSeqs.append(Int(seq)!)
            }
            button.isChecked = isChecked
            y = y + 35
            button.setTitle(title, for: .normal)
            button.addTarget(self, action:#selector(addMultiSelectedAnsSeq), for: .touchUpInside)
            view.addSubview(button)
        }
        if(!moduleProgress.isEmpty){
            getScoreForSelectedOption()
        }
    }
    
    func addTextView(){
        var answerText:String = ""
        if(!moduleProgress.isEmpty){
            let existingProgress = moduleProgress[0] as? [String: Any]
            answerText = (existingProgress?["answerText"] as? String)!
            feedback_success_arr.append(StringConstants.SUBMITTED_SUCCESSFULLY)
        }
        let y:CGFloat = quesTitle.frame.height
        longQuestionTextView = UITextView.init()
        longQuestionTextView.frame = CGRect(x:20,y:y,width:self.view.frame.width-40,height:128)
        longQuestionTextView.textAlignment = NSTextAlignment.justified
        let borderColor = UIColor.lightGray
        longQuestionTextView.layer.borderColor = borderColor.cgColor
        longQuestionTextView.layer.borderWidth = 1.0
        longQuestionTextView.text = answerText
        view.addSubview(longQuestionTextView)
        if(!moduleProgress.isEmpty){
            getScoreForSelectedOption()
        }
    }
   
    private var tableView: UITableView!
    func addTableView(){
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        var height: CGFloat = CGFloat(options.count) * 40.00
        let y:CGFloat = quesTitle.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: y, width: displayWidth, height: height))
        tableView.rowHeight = 40
        tableView.dataSource = self
        tableView.delegate = self
        tableView.setEditing(true, animated: true)
        view.addSubview(tableView)
        seqOptions = options
        if(!moduleProgress.isEmpty){
            var savedOptions:[Any] = []
             for i in 0..<moduleProgress.count{
                let progress = moduleProgress[i] as! [String: Any];
                let answerSeq = progress["answerSeq"] as! String
                let ansJson = getAnswerBySeq(ansSeq: Int(answerSeq)!)
                savedOptions.append(ansJson as Any);
            }
            if isAnsEquals(options1: options, options2: savedOptions) {
                feedback_success_arr.append("Correct Sequence");
            }else{
                feedback_error_arr.append("Incorrect Sequence");
            }
            seqOptions = savedOptions;
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let option = seqOptions[sourceIndexPath.row]
        seqOptions.remove(at: sourceIndexPath.row)
        seqOptions.insert(option, at: destinationIndexPath.row)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seqOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = seqOptions[indexPath.row] as! [String: Any]
        let title = option["title"] as! String
        let seq = option["seq"] as! String
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        cell.textLabel!.text = title
        cell.textLabel?.font = UIFont(name:quesTitle.font.fontName, size: 11.00)
        cell.textLabel!.tag = Int(seq)!
        return cell
    }
    
    func addSwitchView(){
        let y:CGFloat = quesTitle.frame.height + 20
        switcher = UISwitch.init()
        switcher.frame = CGRect(x:30,y:y,width:300,height:128)
        changeSwitcher(sender: switcher)
        if(!moduleProgress.isEmpty){
            let existingProgress = moduleProgress[0] as? [String: Any]
            let answerSeq = existingProgress?["answerSeq"] as! String
            let selectedAnsBySeq = getAnswerBySeq(ansSeq: Int(answerSeq)!)
            var ansTitle = "no"
            if(selectedAnsBySeq != nil){
                ansTitle = selectedAnsBySeq!["title"] as! String
                selectedAnsSeqs.append(Int(answerSeq)!)
            }
            if(ansTitle == "no"){
                switcher.isOn = false
            }else{
                switcher.isOn = true
            }
        }
        switcher.addTarget(self, action:#selector(changeSwitcher), for: .valueChanged)
        view.addSubview(switcher)
        if(!moduleProgress.isEmpty){
            getScoreForSelectedOption()
        }
    }
    
    @objc func changeSwitcher(sender: UISwitch){
        var ansTitle = "no"
        if(sender.isOn){
            ansTitle = "yes"
        }
        let selectedAns = getAnswerByTitle(ansTitle: ansTitle)
        let seq = selectedAns!["seq"] as! String
        selectedAnsSeqs = []
        selectedAnsSeqs.append(Int(seq)!)
    }
    
    func addWebView(){
        let y:CGFloat = quesTitle.frame.height
        let webView: UIWebView = UIWebView.init()
        webView.frame = CGRect(x:16,y:y,width:350,height:300)
        let questionDetail = questionJson["detail"] as! String
        webView.loadHTMLString(questionDetail, baseURL: nil)
        view.addSubview(webView)
    }
    
    func addElearningWebView(){
        let webView:UIWebView = UIWebView()
        webView.delegate = self
        var height = self.view.frame.height;
        height = height - 80
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
                        UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
            height =  view.bounds.size.height
        }
        webView.frame = CGRect(x:0,y:0,width:view.frame.width,height:height)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scalesPageToFit = true
        webView.scrollView.isScrollEnabled = true
        webView.isUserInteractionEnabled = true
        view.addSubview(webView)
        //scrolView.addSubview(webView);
        let urlS = moduleJson["elearningUrl"] as! String
        //urlS = urlS.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlS)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        submitProgress.isHidden = true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
            if(moduleType == "elearning"){
                for view in view.subviews{
                    if view is UIWebView {
                        view.removeFromSuperview()
                    }
                }
                addElearningWebView()
            }
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if(moduleType == "elearning"){
            let moduleSeq = Int(moduleJson["seq"] as! String)!
            let learningPlanseq = Int(moduleJson["learningPlanSeq"] as! String)!
            webView.stringByEvaluatingJavaScript(from: "setUserSeq("+String(loggedInUserSeq)+")")
            webView.stringByEvaluatingJavaScript(from: "setModuleSeq("+String(moduleSeq)+")")
            webView.stringByEvaluatingJavaScript(from: "setlpSeq("+String(learningPlanseq)+")")
        }
    }
    func addWebViewForVideo(){
        let y:CGFloat = quesTitle.frame.height
        let webView: UIWebView = UIWebView.init()
        webView.frame = CGRect(x:0,y:y,width:view.frame.width,height:350)
        let questionDetail = questionJson["detail"] as! String
        var str = questionDetail.trimmingCharacters(in: .whitespacesAndNewlines)
        if(str.hasPrefix("<iframe")){
            let fromIndex = questionDetail.index(questionDetail.startIndex, offsetBy: 7)
            str = questionDetail.substring(from: fromIndex)
            str = "<iframe style=\"width:100%;\" " + str
        }
        webView.loadHTMLString(str, baseURL: nil)
        view.addSubview(webView)
    }
    
    
    func addWebViewforDoc(){
        let y:CGFloat = quesTitle.frame.height
        var height:CGFloat = view.frame.height - submitProgress.frame.height
        height = height - quesTitle.frame.height
        height = height - 80
        
        let webView = UIWebView(frame: CGRect(x:0,y:y,width:view.frame.width,height:height))
        webView.scalesPageToFit = true
        webView.contentMode = UIViewContentMode.scaleAspectFit
        view.addSubview(webView)
        let questionDetail = questionJson["detail"] as! String
        let urlS = StringConstants.DOC_URL + questionDetail
        //urlS = urlS.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlS)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }
    
    func addSliderView(){
        let slider = UISlider(frame: CGRect(x:10,y:quesTitle.frame.height,width:self.view.frame.width-20,height:80))
        sliderLabel = UILabel.init()
        sliderLabel.text = "0 %"
        sliderLabel.frame = CGRect(x:10,y:80,width:50,height:50)
        sliderLabel.font = UIFont(name:quesTitle.font.fontName, size: 11.00)
        
        view.addSubview(slider)
        slider.minimumValue = 0
        slider.maximumValue = 100
        view.addSubview(sliderLabel)
        if(!moduleProgress.isEmpty){
            let existingProgress = moduleProgress[0] as? [String: Any]
            var answerText = (existingProgress?["answerText"] as? String)!
            sliderLabel.text = answerText + " %"
            slider.setValue(Float(answerText)!, animated: true)
            feedback_success_arr.append(StringConstants.SUBMITTED_SUCCESSFULLY)
        }
        slider.addTarget(self, action:#selector(sliderValueChanged), for: .valueChanged)
    }
    
    @objc func addSelectedAnsSeq(sender: UIButton){
        let selectedAnsSeq = sender.tag
        selectedAnsSeqs = []
        selectedAnsSeqs.append(selectedAnsSeq)
    }
    
    @objc func addMultiSelectedAnsSeq(sender: CheckBox){
        let selectedAnsSeq = sender.tag
        if(sender.isChecked){
            selectedAnsSeqs.append(selectedAnsSeq)
        }else{
            if let index = selectedAnsSeqs.index(of: selectedAnsSeq) {
                selectedAnsSeqs.remove(at: index)
            }
        }
    }
    
    @objc func sliderValueChanged(sender: UISlider) {
        //let value = options[Int(sender.value)]
        //sender.value = value
        // Do something else with the value
        let currentValue = Int(sender.value)
        sliderLabel.text = "\(currentValue) %"
    }
    
    func submit(question:[String: Any],isTimeUp:Bool){
        var answerText = ""
        var scores:[Int: Double] = [:]
        let score:Double = 0
        let questionType = question["type"] as! String;
        if(moduleType == StringConstants.LESSION_TYPE_MODULE || isTimeUp){
            ModuleProgressMgr.sharedInstance.saveModuleProgress(response: question, answerText:answerText, score: 0, startDate: parentController.startDate, isTimeUp: isTimeUp)
        }else if(questionType == StringConstants.LONG_TYPE_QUESTION || questionType == StringConstants.ESTIMATE_PERCENT_TYPE_QUESTION){
            feedback_success_arr.append(StringConstants.SUBMITTED_SUCCESSFULLY)
            if(questionType == StringConstants.ESTIMATE_PERCENT_TYPE_QUESTION){
                sliderLabel.text?.removeLast()
                answerText = sliderLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            }else{
                answerText = longQuestionTextView.text
            }
            
            let score = question["maxMarks"] as! String;
            ModuleProgressMgr.sharedInstance.saveModuleProgress(response: question, answerText:answerText, score: Double(score)!, startDate: parentController.startDate, isTimeUp: false)
        }else{
            if (questionType == StringConstants.YES_NO_TYPE_QUESTION) {
                changeSwitcher(sender:switcher)
            }
            if(questionType == StringConstants.SEQUENCING){
                let isInRightOrder = addSelectedSequenceOrderSeq()
                if (isInRightOrder) {
                    let score = question["maxMarks"] as! String;
                    feedback_success_arr.append("Correct Sequence");
                }else{
                    feedback_error_arr.append("Incorrect Sequence");
                }
                let ansSeq = selectedAnsSeqs.first
                scores[ansSeq!] = score;
            }else{
                 scores = getScoreForSelectedOption()
            }
           
            ModuleProgressMgr.sharedInstance.saveModuleProgress(response: question, ansSeqs: selectedAnsSeqs, scores: scores, startDate: parentController.startDate)
        }
        self.handleViews()
        if((!isTimeUp && itemIndex + 1 == totalQuestion) ||
                (parentController.submittedQuestionCount+1 == totalQuestion)){
            executeSubmitModuleCall()
        }
        if(!isTimeUp){
            parentController.createPageViewController(itemIndex: itemIndex)
        }
         parentController.submittedQuestionCount =  parentController.submittedQuestionCount + 1
        if(!isShowFeedback && !isTimeUp){
            goToNextPage()
        }
        parentController.startDate = Date.init()
       
    }
    
    func executeSubmitModuleCall(){
        let moduleSeq = Int(questionJson["moduleSeq"] as! String)!;
        let learningPlanSeq = Int(questionJson["learningPlanSeq"] as! String)!;
        let isNetworkAvailable = Reachability1.isConnectedToNetwork()
        if(isNetworkAvailable){
            var jsonString = ModuleProgressMgr.sharedInstance.getExistingProgressJosnStringForModule(moduleSeq: moduleSeq, learningPlanSeq: learningPlanSeq)
            jsonString = jsonString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,jsonString]
            let apiUrl: String = MessageFormat.format(pattern: StringConstants.SUBMIT_MODULE_PROGRESS, args: args)
            var success : Int = 0
            var message : String? = nil
            ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                    success = json["success"] as! Int
                    message = json["message"] as? String
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if(success == 1){
                            ModuleProgressMgr.sharedInstance.deleteModuleProgress(moduleSeq: moduleSeq, learningPlanSeq: learningPlanSeq)
                            self.performSegue(withIdentifier: "showTrainingTabs", sender: self)
                            self.showAlert(message: message!)
                        }
                    }
                } catch let parseError as NSError {
                    self.showAlert(message: parseError.description)
                }
            })
        }else{
            let moduleMgr = ModuleMgr.sharedInstance
            moduleMgr.savePendingModule(moduleSeq: moduleSeq,learningPlanSeq: learningPlanSeq)
            self.performSegue(withIdentifier: "showTrainingTabs", sender: self)
            self.showAlert(message: "Training Completed")
        }
    }
    
    func executeSaveActivityCall(){
        if(moduleProgress.isEmpty && itemIndex == 0 && !isActivitySaved){
            let randomQuestionKeys:[String] = parentController.randomQuestionKeys
            let moduleSeq = Int(moduleJson["seq"] as! String)!;
            let learningPlanSeq = Int(moduleJson["learningPlanSeq"] as! String)!;
            var jsonString = ModuleProgressMgr.sharedInstance.getActivityJsonString(moduleSeq: moduleSeq, learningPlanSeq: learningPlanSeq,randomQuesitionKeys: randomQuestionKeys)
            jsonString = jsonString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let args: [Any] = [self.loggedInUserSeq,self.loggedInCompanySeq,jsonString]
            let apiUrl: String = MessageFormat.format(pattern: StringConstants.SAVE_ACTIVITY, args: args)
            var success : Int = 0
            var message : String? = nil
            ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                    success = json["success"] as! Int
                    message = json["message"] as? String
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if(success == 1){
                            self.isActivitySaved = true
                        }
                    }
                } catch let parseError as NSError {
                    self.showAlert(message: parseError.description)
                }
            })
        }
    }
    
    func getScoreForSelectedOption()->[Int:Double]{
        var scores:[Int:Double] = [:];
        for ans in selectedAnsSeqs{
            let selectedAns = getAnswerBySeq(ansSeq: ans)
            if(selectedAns == nil){
                return scores
            }
            let scoreStr = selectedAns!["marks"] as! String
            let seq = selectedAns!["seq"] as! String
            var score:Double = 0
            if(!scoreStr.isEmpty){
                score = Double(scoreStr)!
                scores[Int(seq)!] = score
            }
            var feedback = selectedAns!["feedback"] as? String;
            if(moduleType == "quiz") {
                if (score > 0) {
                    if (feedback == nil || feedback != "null") {
                        feedback = "Correct";
                    }
                    feedback_success_arr.append(feedback!);
                } else {
                    if (feedback == nil || feedback != "null") {
                        feedback = "Incorrect";
                    }
                    feedback_error_arr.append(feedback!);
                }
            }else{
                feedback_success_arr.append("Submitted");
            }
        }
        return scores
    }
    
    func getAnswerBySeq(ansSeq:Int)->[String: Any]?{
        for i in 0..<options.count{
            let option = options[i] as! [String: Any]
            let optionSeq = option["seq"] as! String
            if(String(ansSeq) == optionSeq){
                return option
            }
        }
        return nil
    }
    
    func getAnswerByTitle(ansTitle:String)->[String: Any]?{
        for i in 0..<options.count{
            let option = options[i] as! [String: Any]
            let title = option["title"] as! String
            if(title == ansTitle){
                return option
            }
        }
        return nil
    }
    
    func addSelectedSequenceOrderSeq()->Bool{
        var flag = false;
        var isInRightOrder = true;
        for i in 0..<seqOptions.count{
            let option = seqOptions[i] as! [String: Any]
            let optionSeq = option["seq"] as! String
            selectedAnsSeqs.append(Int(optionSeq)!);
            let ansJson = options[i] as! [String: Any];
            let seq = ansJson["seq"] as! String;
            if (!flag){
                if (seq != optionSeq) {
                    isInRightOrder = false;
                    flag = true;
                }
            }
        }
        return isInRightOrder;
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func toString(jsonObject:[Any])->String{
        let jsonString: String!
        do {
            let postData : NSData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
            jsonString = NSString(data: postData as Data, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            jsonString = ""
        }
        return jsonString!
    }
    
    private func isOptionSeqExistsInAnwers(optionSeq: String)->Bool{
        var flag:Bool = false
        for i in 0..<moduleProgress.count{
            let existingProgress = moduleProgress[i] as? [String: Any]
            let existingAnswerSeq = existingProgress?["answerSeq"] as! String
            if(existingAnswerSeq == optionSeq ){
                flag = true
                break
            }
        }
        return flag
    }
    private func isOptionTitleExistsInAnwers(optionSeq: String)->Bool{
        var flag:Bool = false
        for i in 0..<moduleProgress.count {
            let existingProgress = moduleProgress[i] as? [String: Any]
            let existingAnswerSeq = existingProgress?["answerSeq"] as! String
            if(existingAnswerSeq == optionSeq ){
                flag = true
                break
            }
        }
        return flag
    }
    
    private func handleViews(){
        if(moduleType == StringConstants.LESSION_TYPE_MODULE){
            submitProgress.setTitle("Mark as read", for: .normal)
        }else{
            submitProgress.setTitle("Submit", for: .normal)
        }
        if(!moduleProgress.isEmpty){
           submitProgress.isEnabled = false
           okButton.isHidden = false
        }else{
           submitProgress.isEnabled = true
           okButton.isHidden = true
        }
        showFeedback()
    }
    
    private func showFeedback(){
        if(isShowFeedback){
            var successText:String = "";
            for feedback in feedback_success_arr {
                successText += feedback + "\n"
            }
            var errorText:String = "";
            for feedback in feedback_error_arr {
                errorText += feedback + "\n"
            }
            if(!successText.isEmpty){
                successText.removeLast()
                feedbackSuccessLabel.isHidden = false
                feedbackSuccessLabel.text = successText
            }
            if(!errorText.isEmpty){
                errorText.removeLast()
                feebackErrorLabel.isHidden = false
                feebackErrorLabel.text = errorText
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
     override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "showTrainingTabs") {
            //get a reference to the destination view controller
            let destinationVC:MainTabController = segue.destination as! MainTabController
            //set properties on the destination view controller
            destinationVC.isTraining = true
            //etc...
        }
    }
    
    func isAnsEquals(options1:[Any],options2:[Any])->Bool{
        for i in 0..<options1.count{
            let option1 = options1[i] as! [String: Any]
            let option2 = options2[i] as! [String: Any]
            let seq1 = option1["seq"] as! String
            let seq2 = option2["seq"] as! String
            if(seq1 != seq2){
                return false
            }
        }
        return true
    }
    
    
}
