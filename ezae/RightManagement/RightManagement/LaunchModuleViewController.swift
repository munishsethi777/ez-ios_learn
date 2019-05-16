//
//  DynamicViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 01/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//
import UIKit
import GameKit
class LaunchModuleViewController: UIViewController,UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var loggedInUserSeq: Int = 0
    var loggedInCompanySeq: Int = 0
    @IBOutlet weak var moduleTitle: UILabel!
    @IBOutlet weak var pageNoLabel: UILabel!
    @IBOutlet weak var marksLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    var isReattempt:Bool = false
    var moduleSeq: Int = 0
    var lpSeq: Int = 0
    var jsonResponse: [String: Any] = [:]
    var questionJsonArr: [Any] = []
    var moduleJson: [String: Any] = [:]
    var isNext:Bool = false;
    var activityData:[String: Any] = [:]
    var currentQuestion:[String: Any] = [:]
    var timeAllowed:String = ""
    var seconds = 60 //This variable will hold a starting value of seconds. It could be any amount above 0.
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    var resumeTapped = false
    var childItemController: PageItemController!
    var progress: Int = 0
    var startDate: Date!
    var submittedQuestionCount:Int = 0
    var randomQuestionKeys:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loggedInUserSeq =  PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        self.loggedInCompanySeq =  PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
       
        getModuleDetail()
        setupPageControl()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
       self.performSegue(withIdentifier: "showMainTabs", sender: self)
    }
    var pageViewController: UIPageViewController?
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPageViewController(itemIndex:Int) {
        let moduleType = moduleJson["moduletype"] as! String
        if(moduleType == "quiz"){
           marksLabel.isHidden = false
        }else{
            marksLabel.isHidden = true
        }
       
        questionJsonArr = moduleJson["questions"] as! [Any]
        let activity = moduleJson["activityData"] as? [String: Any]
        if(activity != nil){
            self.activityData = activity!
            let progressStr = activityData["progress"] as! String
            progress = Int(progressStr)!
        }
        moduleTitle.text = moduleJson["title"] as! String
        let pageController = self.storyboard!.instantiateViewController(withIdentifier: "PageController") as! UIPageViewController
        pageController.dataSource = self
        
        if questionJsonArr.count > 0 {
            setPaggerLabel(page: itemIndex+1)
        }
        let firstController = getItemController(itemIndex: itemIndex)!
        let startingViewControllers = [firstController]
        pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        pageController.delegate = self
        pageViewController = pageController
        addChildViewController(pageViewController!)
        let childView:UIView = pageViewController!.view
        childView.frame = CGRect(x: 0, y: 60, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-20);
        self.view.addSubview(childView)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    func runTimer() {
        if(timeAllowed != "0" && progress < 100){
            timerLabel.isHidden = false
            var time = Int(Double(timeAllowed)! * 60)
            time -= ModuleProgressMgr.sharedInstance.getTimeConsumed(questions: questionJsonArr)
            seconds = Int(time) // min to seconds
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        }else{
            timerLabel.isHidden = true
        }
    }
    
    @objc func updateTimer() {
        if(seconds > 0){
            seconds -= 1     //This will decrement(count down)the seconds.
            timerLabel.text = timeString(time: TimeInterval(seconds)) //This will update the label.
        }else{
            timer.invalidate()
            submitPendingQuestions()
        }
    }
    
    func submitPendingQuestions(){
        submittedQuestionCount = ModuleProgressMgr.sharedInstance.getTotalSubmittedProgressByModule(questions:questionJsonArr)
        let totalQuestionCount = questionJsonArr.count
        let count = submittedQuestionCount
        for i in count..<totalQuestionCount {
            let questionJson = questionJsonArr[i] as! [String: Any];
            childItemController.submit(question: questionJson, isTimeUp: true)
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }
    
    private func getQuesProgress(itemIndex: Int)->[Any]{
        let questionJson = questionJsonArr[itemIndex] as! [String: Any]
        let questionSeq = Int(questionJson["seq"] as! String)!
        let moduleSeq = Int(questionJson["moduleSeq"] as! String)!
        let learningPlanseq = Int(questionJson["learningPlanSeq"] as! String)!
        let localProgress = ModuleProgressMgr.sharedInstance.getExistingProgressArray(questionSeq: questionSeq, moduleSeq: moduleSeq, learningPlanSeq: learningPlanseq)
        var moduleProgress = questionJson["progress"] as! [Any]
        moduleProgress = localProgress + moduleProgress
        return moduleProgress
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! PageItemController
        if itemController.itemIndex+1 < questionJsonArr.count {
            isNext = true;
            return getItemController(itemIndex: itemController.itemIndex+1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! PageItemController
        if itemController.itemIndex > 0 {
            isNext = false
            return getItemController(itemIndex: itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]){
        let itemController = pendingViewControllers[0] as! PageItemController
        let count = itemController.pageNo
        setPaggerLabel(page: count)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool){
        let p = 0
    }
    
    func setPaggerLabel(page: Int){
        let questionJson = moduleJson["questions"] as! [Any]
        let totalQuesCount = questionJson.count
        var countStr = " Pages"
        let moduleType = moduleJson["moduletype"] as! String
        if(moduleType == "quiz"){
            countStr = " Questions"
        }
        if questionJsonArr.count > 1 {
            pageNoLabel.text = String(page) + " of " + String(totalQuesCount) + countStr
        }
        let question = questionJson[page-1] as! [String: Any]
        var marks = question["maxMarks"] as? String
        if(marks == nil){
            marks = "0"
        }
        marksLabel.text = "Marks:" + marks!
    }
    
    private func applyMaxQuestionCondition(){
        let maxQuestionCountStr = moduleJson["maxquestions"] as! String
        let maxQuestionCount = Int(maxQuestionCountStr)!
        let activity = moduleJson["activityData"] as? [String: Any]
        if(maxQuestionCount > 0 && maxQuestionCount < questionJsonArr.count) {
            var randomQuestions:[Any] = []
            if(activity != nil){
                let existingRandomQues = activity!["randomquestionkeys"] as? String;
                if(existingRandomQues != nil){
                    let quesSeqArr = existingRandomQues!.components(separatedBy: ",")
                    for quesSeq in quesSeqArr{
                        for question in questionJsonArr {
                            let questionJson = question as! [String: Any]
                            let seq = questionJson["seq"] as! String;
                            if (quesSeq == seq) {
                                randomQuestionKeys.append(seq)
                                randomQuestions.append(questionJson)
                                break;
                            }
                        }
                    }
                }else{
                    randomQuestions = getRandomQuestions(maxQuestion: maxQuestionCount, questions: questionJsonArr)
                }
            }else{
                randomQuestions = getRandomQuestions(maxQuestion: maxQuestionCount, questions: questionJsonArr)
            }
            moduleJson["questions"] = randomQuestions
        }
    }
    
    private func getRandomQuestions(maxQuestion:Int,questions:[Any])->[Any]{
        var randomQuestions:[Any] = []
        for i in 0..<maxQuestion {
            let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: questions.count)
            let randomQuestion = questions[randomNumber] as! [String:Any]
            let questionSeq = randomQuestion["seq"] as! String
            randomQuestions.append(randomQuestion)
            randomQuestionKeys.append(questionSeq)
        }
        return randomQuestions
    }
    
    private func getItemController(itemIndex: Int) -> PageItemController? {
         let moduleType = moduleJson["moduletype"] as! String
        if itemIndex < questionJsonArr.count || moduleType == "elearning" {
            if(itemIndex > 0){
                let progress = getQuesProgress(itemIndex: itemIndex-1)
                if(progress.isEmpty){
                    return nil
                }
            }
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "ItemController") as! PageItemController
            pageItemController.moduleJson = moduleJson
            pageItemController.activityData = activityData
            pageItemController.itemIndex = itemIndex
            let pageNo = itemIndex + 1
            pageItemController.parentController = self
            pageItemController.pageNo = pageNo
            if(questionJsonArr.count > 0){
                pageItemController.questionJson = questionJsonArr[itemIndex] as! [String: Any]
            }
            childItemController = pageItemController
            return pageItemController
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return questionJsonArr.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func getModuleDetail(){
        let args: [Any] = [self.loggedInUserSeq,self.moduleSeq,self.lpSeq,self.isReattempt]
        let apiUrl: String = MessageFormat.format(pattern: StringConstants.GET_MODULE_DETAIL, args: args)
        var success : Int = 0
        var message : String? = nil
        ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                success = json["success"] as! Int
                message = json["message"] as? String
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if(success == 1){
                        self.jsonResponse = json
                        self.moduleJson =  json["module"] as! [String: Any]
                        self.timeAllowed = (self.moduleJson["timeallowed"] as? String)!
                        self.questionJsonArr = self.moduleJson["questions"] as! [Any]
                        self.applyMaxQuestionCondition()
                        self.createPageViewController(itemIndex:0)
                        self.startDate = Date.init()
                        self.runTimer()
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
    func goNextPage(index:Int) {
        let viewController = self.pageViewController?.viewControllers
        let nextViewController =  self.pageViewController?.dataSource?.pageViewController( self.pageViewController!, viewControllerAfter: viewController![0] )
        self.pageViewController?.setViewControllers([nextViewController!], direction:
            UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        setPaggerLabel(page: index+1)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "showMainTabs") {
            //get a reference to the destination view controller
            let destinationVC:MainTabController = segue.destination as! MainTabController
            //set properties on the destination view controller
            destinationVC.isTraining = true
            //etc...
        }
    }
    
}
