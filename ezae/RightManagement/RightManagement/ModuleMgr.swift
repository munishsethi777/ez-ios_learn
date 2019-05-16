//
//  ModuleMgr.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 10/03/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
import CoreData
class ModuleMgr{
    static let sharedInstance = ModuleMgr()
    let coreDataManager = CoreDataManager(modelName: "right")
    func savePendingModule(moduleSeq:Int,learningPlanSeq:Int){
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        let pendingModule = NSEntityDescription.insertNewObject(forEntityName: "PendingModule", into: coreDataManager.managedObjectContext) as! PendingModule
        let now = NSDate.init()
        pendingModule.dated = now as Date
        pendingModule.moduleseq = Int32(moduleSeq)
        pendingModule.userseq = Int32(userSeq)
        pendingModule.learningplanseq = Int32(learningPlanSeq)
        do {
            try coreDataManager.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func getPendingModuleToUpload()->[PendingModule]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PendingModule")
        let userSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
        let p1 = NSPredicate(format: "userseq == %d", userSeq)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
        fetchRequest.predicate = predicate
        do {
            let fetchedProgress = try coreDataManager.managedObjectContext.fetch(fetchRequest) as? [PendingModule]
            return fetchedProgress!
        } catch {
            fatalError("Failure to get context: \(error)")
        }
    }
    
    func delete(moduleSeq: Int ,learningPlanSeq: Int){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PendingModule")
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
    
    
    
}
