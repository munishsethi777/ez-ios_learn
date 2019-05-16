//
//  CompanyUserMgr.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 06/01/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import UIKit
import CoreData
class CompanyUserMgr{
    static let sharedInstance = CompanyUserMgr()
    let coreDataManager = CoreDataManager(modelName: "right")
    func saveUsersFromResponse(response:[String:Any]){
        let jsonArray = response["users"] as! [Any];
        self.deleteAll();
        let companySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        for i in 0..<jsonArray.count{
            let userJson = jsonArray[i] as! [String: Any]
            let seq = userJson["seq"] as! String
            let type = userJson["type"] as! String
            let userName = userJson["username"] as! String
            let image = userJson["image"] as? String
            var fullName = userJson["name"] as? String
            if(fullName == nil){
                fullName = userName
            }
            let companyUser = NSEntityDescription.insertNewObject(forEntityName: "CompanyUsers", into: coreDataManager.managedObjectContext) as! CompanyUsers
            companyUser.companyseq = Int32(companySeq)
            companyUser.userseq = Int32(seq)!
            companyUser.username = userName
            companyUser.userimage = image
            companyUser.usertype = type
            companyUser.fullname = fullName
            do {
                try coreDataManager.managedObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func getAllCompanyUsers()->[CompanyUsers]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CompanyUsers")
        let companySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq();
        let p1 = NSPredicate(format: "companyseq == %d", companySeq)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
        fetchRequest.predicate = predicate
        do {
            let fetchedProgress = try coreDataManager.managedObjectContext.fetch(fetchRequest) as! [CompanyUsers]
            return fetchedProgress
        } catch {
            fatalError("Failure to get context: \(error)")
        }
    }
    
    private func deleteAll(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CompanyUsers")
        let companySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq()
        let p1 = NSPredicate(format: "companyseq == %d", companySeq)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            let result = try coreDataManager.managedObjectContext.execute(deleteRequest)
        }
        catch let error as NSError {
            let messages = error
        }
    }
}
