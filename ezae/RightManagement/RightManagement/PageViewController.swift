//
//  PageViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 01/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController
{

    var currentPage: Int = 0;
    var moduleSeq: Int = 0;
    var lpSeq: Int = 0;
    var loggedInUserSeq: Int!
    var loggedInCompanySeq: Int!
    fileprivate lazy var pages: [UIViewController] = []
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = nil
        self.delegate   = nil
        self.loggedInUserSeq =  PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        self.loggedInCompanySeq =  PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        
    }
    
    func goToNext(){
        if(currentPage < pages.count){
            currentPage = currentPage + 1
        }
        let currentController = pages[currentPage]
        setViewControllers([currentController], direction: .forward, animated: true, completion: nil)
    }
    func goToPrevious(){
        if(currentPage > 1){
            currentPage = currentPage - 1
        }
        let currentController = pages[currentPage]
        setViewControllers([currentController], direction: .forward, animated: true, completion: nil)
    }
    
    func getModuleDetail(){
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
                        self.loadModuleController(response: json)
                    }else{
                        self.showAlert(message: message!)
                    }
                }
            } catch let parseError as NSError {
                self.showAlert(message: parseError.description)
            }
        })
    }
    
    func loadModuleController(response: [String: Any]){
        let modulesJson = response["module"] as! [String: Any]
        let questionJsonArr = modulesJson["question"] as! [Any]
        for var i in (0..<questionJsonArr.count).reversed(){
//            let questionJson = questionJsonArr[i] as! [String: Any]
//            let controller = LaunchModuleViewController()
//            controller.questionJson = questionJson
//            pages.append(controller)
        }
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
       
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension PageViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return pages.last }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
}

extension PageViewController: UIPageViewControllerDelegate { }


