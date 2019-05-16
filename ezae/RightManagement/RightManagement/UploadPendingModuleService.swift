//
//  UploadPendingModuleService.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 10/03/18.
//  Copyright © 2018 Munish Sethi. All rights reserved.
//

import Foundation
class UploadPendingModuleService  {
    static let sharedInstance = UploadPendingModuleService()
    
    func uploadPendingProgress(){
        let moduleMgr = ModuleMgr.sharedInstance
        let moduleProgressMgr = ModuleProgressMgr.sharedInstance
        let pendingModules = moduleMgr.getPendingModuleToUpload();
        for var i in 0..<pendingModules.count{
            let pendingModule = pendingModules[i]
            let moduleSeq = Int(pendingModule.moduleseq);
            let learningPlanSeq = Int(pendingModule.learningplanseq);
            let pendingProgressJson = moduleProgressMgr.getExistingProgressJosnStringForModule(moduleSeq: Int(moduleSeq),learningPlanSeq: Int(learningPlanSeq))
            self.executeSubmitModuleCall(jsonString: pendingProgressJson, moduleSeq:
                moduleSeq, learningPlanSeq: learningPlanSeq)
        }
    }
    
    func executeSubmitModuleCall(jsonString:String,moduleSeq:Int,learningPlanSeq:Int){
            let json = jsonString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let loggedInUserSeq = PreferencesUtil.sharedInstance.getLoggedInUserSeq();
            let loggedInCompanySeq = PreferencesUtil.sharedInstance.getLoggedInCompanySeq();
            let args: [Any] = [loggedInUserSeq,loggedInCompanySeq,json]
            let apiUrl: String = MessageFormat.format(pattern: StringConstants.SUBMIT_MODULE_PROGRESS, args: args)
            var success : Int = 0
            ServiceHandler.instance().makeAPICall(url: apiUrl, method: HttpMethod.GET, completionHandler: { (data, response, error) in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String: Any]
                    success = json["success"] as! Int
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if(success == 1){
                            ModuleProgressMgr.sharedInstance.deleteModuleProgress(moduleSeq: moduleSeq, learningPlanSeq: learningPlanSeq)
                            ModuleMgr.sharedInstance.delete(moduleSeq: moduleSeq, learningPlanSeq: learningPlanSeq)
                        }
                    }
                } catch let parseError as NSError {
                   
                }
            })
     }
    
}
