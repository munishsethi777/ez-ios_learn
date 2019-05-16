//
//  EventViewController.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 22/01/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
import SSCalendar
class EventViewController :SSCalendarAnnualViewController{
    var loggedInUserSeq:Int!
    var loggedInCompanySeq:Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        getEvents()
    }
    fileprivate func getEvents(){
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
        let color = UIColor.white
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

    func showAlert(message: String){
        let alert = UIAlertController(title: "API Exception", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
