//
//  ModuleProgressMgr.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 14/12/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import Foundation
import CoreData
class ModuleProgressMgr{
    static let sharedInstance = ModuleProgressMgr()
    let coreDataManager = CoreDataManager(modelName: "right")
    func saveModuleProgress(response: [String: Any],answerText:String, score:Double, startDate:Date, isTimeUp:Bool){
        let moduleProgress = NSEntityDescription.insertNewObject(forEntityName: "ModuleProgress", into: coreDataManager.managedObjectContext) as! ModuleProgress
        let moduleSeq = response["moduleSeq"] as! String;
        let questionSeq = response["seq"] as! String;
        let learningPlanSeq = response["learningPlanSeq"] as! String;
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        moduleProgress.ansseq = 0
        moduleProgress.anstext = answerText
        moduleProgress.startdate = startDate as NSDate as Date
        moduleProgress.enddate = NSDate.init() as Date
        moduleProgress.moduleseq = Int32(moduleSeq)!
        moduleProgress.questionseq = Int32(questionSeq)!
        moduleProgress.learningplanseq = Int32(learningPlanSeq)!
        moduleProgress.isuploaded = false
        moduleProgress.istimeup = isTimeUp
        moduleProgress.score = score
        moduleProgress.userseq = Int32(userSeq)
        do {
            try coreDataManager.managedObjectContext.save()
        } catch {
            fatalError("Failure to save module progress: \(error)")
        }
    }
    
    func saveModuleProgress(response: [String: Any],ansSeqs:[Any],scores:[Int: Double],startDate:Date){
        let moduleSeq = response["moduleSeq"] as! String;
        let questionSeq = response["seq"] as! String;
        let learningPlanSeq = response["learningPlanSeq"] as! String;
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        for ansSeq in ansSeqs {
            let moduleProgress = NSEntityDescription.insertNewObject(forEntityName: "ModuleProgress", into: coreDataManager.managedObjectContext) as! ModuleProgress
            let seq:Int = ansSeq as! Int
            moduleProgress.ansseq = Int32(seq)
            moduleProgress.startdate = startDate as NSDate as Date
            let now = NSDate.init()
            moduleProgress.enddate = now as Date
            moduleProgress.moduleseq = Int32(moduleSeq)!
            moduleProgress.questionseq = Int32(questionSeq)!
            moduleProgress.learningplanseq = Int32(learningPlanSeq)!
            moduleProgress.isuploaded = false
            var score:Double = 0
            if let val = scores[seq] {
                score = val
            }
            moduleProgress.score = score
            moduleProgress.userseq = Int32(userSeq)
            do {
                try coreDataManager.managedObjectContext.save()
            } catch {
                fatalError("Failure to save module progress: \(error)")
            }
        }
    }
    
    func getActivityJsonString(moduleSeq:Int,learningPlanSeq:Int,randomQuesitionKeys:[String])->String{
        var activityJson:[String: Any] = [:]
        activityJson["moduleSeq"] = moduleSeq
        activityJson["learningPlanSeq"] = learningPlanSeq
        activityJson["userSeq"] = PreferencesUtil.sharedInstance.getLoggedInUserSeq()
        activityJson["score"] = 0
        activityJson["progress"] = 0
        var randomQuestionKeysStr = ""
        if(!randomQuesitionKeys.isEmpty){
            randomQuestionKeysStr = randomQuesitionKeys.joined(separator: ",")
        }
        activityJson["randomQuestionKeys"] = randomQuestionKeysStr
        let jsonString = toJsonString(jsonObject: activityJson)
        return jsonString
    }
    
    func getExistingProgressForQuestion(questionSeq: Int,moduleSeq: Int ,learningPlanSeq: Int)->[ModuleProgress]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ModuleProgress")
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        let p1 = NSPredicate(format: "userseq == %d", userSeq)
        let p2 = NSPredicate(format: "moduleseq == %d", moduleSeq)
        let p3 = NSPredicate(format: "questionseq == %d", questionSeq)
        let p4 = NSPredicate(format: "learningplanseq == %d", learningPlanSeq)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2,p3,p4])
        fetchRequest.predicate = predicate
        do {
            let fetchedProgress = try coreDataManager.managedObjectContext.fetch(fetchRequest) as! [ModuleProgress]
            return fetchedProgress
        } catch {
            fatalError("Failure to get context: \(error)")
        }
    }
    
    func getExistingProgressForModule(moduleSeq: Int ,learningPlanSeq: Int)->[ModuleProgress]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ModuleProgress")
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        let p1 = NSPredicate(format: "userseq == %d", userSeq)
        let p2 = NSPredicate(format: "moduleseq == %d", moduleSeq)
        let p3 = NSPredicate(format: "learningplanseq == %d", learningPlanSeq)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2,p3])
        fetchRequest.predicate = predicate
        do {
            let fetchedProgress = try coreDataManager.managedObjectContext.fetch(fetchRequest) as? [ModuleProgress]
            return fetchedProgress!
        } catch {
            fatalError("Failure to get context: \(error)")
        }
    }
    
    func isProgressForModule(moduleSeq: Int ,learningPlanSeq: Int)->Bool{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ModuleProgress")
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        let p1 = NSPredicate(format: "userseq == %d", userSeq)
        let p2 = NSPredicate(format: "moduleseq == %d", moduleSeq)
        let p3 = NSPredicate(format: "learningplanseq == %d", learningPlanSeq)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2,p3])
        fetchRequest.predicate = predicate
        do {
            let fetchedProgress = try coreDataManager.managedObjectContext.count(for: fetchRequest)
            return fetchedProgress > 0
        } catch {
            fatalError("Failure to get context: \(error)")
        }
    }
    
    func getExistingProgressArray(questionSeq: Int,moduleSeq: Int ,learningPlanSeq: Int)->[Any]{
        var progressArr:[Any] = []
        let moduleProgressList = getExistingProgressForQuestion(questionSeq:questionSeq,moduleSeq: moduleSeq, learningPlanSeq: learningPlanSeq)
        for i in 0..<moduleProgressList.count{
            let moduleProgress = moduleProgressList[i]
            let moduleProgressArr = getArray(moduleProgress: moduleProgress)
            progressArr.append(moduleProgressArr)
        }
        return progressArr
    }
    
    func getExistingProgressJosnStringForModule(moduleSeq: Int ,learningPlanSeq: Int)->String{
        let fetchedProgress = getExistingProgressForModule(moduleSeq: moduleSeq, learningPlanSeq: learningPlanSeq)
        let jsonString = getJsonString(progressArr: fetchedProgress)
        return jsonString
    }
    
    func getJsonString(progressArr:[ModuleProgress])->String{
        var jsonString:String = ""
        for i in 0..<progressArr.count {
            var progressJson:[String: Any] = [:]
            let moduleProgress = progressArr[i]
            progressJson = getArray(moduleProgress: moduleProgress)
            let str = toJsonString(jsonObject: progressJson)
            jsonString.append(str + ",")
        }
        jsonString = String(jsonString.dropLast())
        return "["+jsonString+"]"
    }
    
    private func getArray(moduleProgress:ModuleProgress)->[String: Any]{
        var progressJson:[String: Any] = [:]
        progressJson["moduleSeq"] = moduleProgress.moduleseq
        progressJson["learningPlanSeq"] =  moduleProgress.learningplanseq
        progressJson["answerSeq"] = String(moduleProgress.ansseq)
        progressJson["answerText"] = moduleProgress.anstext
        progressJson["questionSeq"] = moduleProgress.questionseq
        progressJson["progress"] = 100
        progressJson["dated"] = DateUtil.sharedInstance.dateToString(date: moduleProgress.enddate! as Date,format:
            DateUtil.format1)
        progressJson["startDate"] = DateUtil.sharedInstance.dateToString(date: moduleProgress.startdate! as Date,format: DateUtil.format1)
        progressJson["isTimeUp"]  = moduleProgress.istimeup
        progressJson["userSeq"] = moduleProgress.userseq
        progressJson["score"] = moduleProgress.score
        return progressJson
    }
    
    func deleteModuleProgress(moduleSeq: Int ,learningPlanSeq: Int){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ModuleProgress")
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        let p1 = NSPredicate(format: "userseq == %d", userSeq)
        let p2 = NSPredicate(format: "moduleseq == %d", moduleSeq)
        let p3 = NSPredicate(format: "learningplanseq == %d", learningPlanSeq)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            let result = try coreDataManager.managedObjectContext.execute(deleteRequest)
        }
        catch let error as NSError {
            //Error handling
        }
    }
    
    func toJsonString(jsonObject:Any)->String{
        let jsonString: String!
        do {
            let postData : NSData = try JSONSerialization.data(withJSONObject: jsonObject, options:[]) as NSData
            jsonString = NSString(data: postData as Data, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            jsonString = ""
        }
        return jsonString!
    }
    
    func getTotalSubmittedProgressByModule(questions:[Any])->Int{
        var totalSubmittedProgress = 0
        for q in questions{
            let question = q as! [String: Any]
            let moduleSeq = question["moduleSeq"] as! String
            let seq = question["seq"] as! String
            let learningPlanSeq = question["learningPlanSeq"] as! String
            let progress = question["progress"] as! [Any]
            if(!progress.isEmpty){
                totalSubmittedProgress = totalSubmittedProgress + 1
            }
            let localProgress = getExistingProgressArray(questionSeq: Int(seq)!, moduleSeq: Int(moduleSeq)!, learningPlanSeq: Int(learningPlanSeq)!)
            if(!localProgress.isEmpty){
                totalSubmittedProgress = totalSubmittedProgress + 1
            }
        }
        return totalSubmittedProgress
    }
    
    func getTimeConsumed(questions:[Any])->Int{
        var diffInSeconds = 0;
        for q in questions {
            let question = q as! [String: Any]
            let moduleSeq = question["moduleSeq"] as! String
            let seq = question["seq"] as! String
            let learningPlanSeq = question["learningPlanSeq"] as! String
            let progress = question["progress"] as! [Any]
            if(!progress.isEmpty){
                let progJson = progress[0] as! [String: Any];
                diffInSeconds += getTimeDiffFromQuesProg(progressJson:progJson);
            }
            let localProgress = getExistingProgressArray(questionSeq: Int(seq)!, moduleSeq: Int(moduleSeq)!, learningPlanSeq: Int(learningPlanSeq)!)
            if(!localProgress.isEmpty){
                let localProgJson = localProgress[0] as! [String: Any];
                diffInSeconds += getTimeDiffFromQuesProg(progressJson:localProgJson);
            }
        }
        return diffInSeconds;
    }
    
    func getTimeDiffFromQuesProg(progressJson:[String: Any])->Int{
        let startDateStr = progressJson["startDate"] as! String;
        let endDateStr = progressJson["dated"] as! String;
        let startDate = DateUtil.sharedInstance.stringToDate(dateStr: startDateStr)
        let endDate = DateUtil.sharedInstance.stringToDate(dateStr: endDateStr)
        let timeInterval = currentTimeInMiliseconds(date: endDate) - currentTimeInMiliseconds(date: startDate)
        return timeInterval;
    }
    
    func currentTimeInMiliseconds(date:Date) -> Int {
        let since1970 = date.timeIntervalSince1970
        return Int(since1970)
    }
}
