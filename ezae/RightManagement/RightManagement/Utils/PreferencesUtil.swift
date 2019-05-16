//
//  PreferencesUtil.swift
//  RightManagement
//
//  Created by Baljeet Gaheer on 15/11/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import Foundation
class PreferencesUtil{
    static let sharedInstance = PreferencesUtil()
    static let LOGGED_IN_USER_SEQ_KEY = "loggedInUserSeq"
    static let LOGGED_IN_COMPANY_SEQ_KEY = "loggedInCompanySeq"
    static let LOGGED_IN_DEVICE_ID = "deviceId"
    static let NOTIFICATION_STATE = "notificationState"
    static let NOTIFICATION_ENTITY_SEQ = "notificationEntitySeq"
    static let FROM_USER_NAME = "fromUserName";
    static let LP_SEQ = "lpSeq";
    static let NOTIFICATION_ENTITY_TYPE = "notificationEntityType"
    static let APP_ACTIVE_STATE = "AppActiveState"
    
    func setDeviceId(deviceId:String){
        setValue(key: PreferencesUtil.LOGGED_IN_DEVICE_ID,value: deviceId)
    }
    func getDeviceId()->String?{
        return getValue(key: PreferencesUtil.LOGGED_IN_DEVICE_ID)
    }
    
    func setLoggedInUserSeq(userSeq:Int){
        setValue(key: PreferencesUtil.LOGGED_IN_USER_SEQ_KEY,value: userSeq)
    }
    
    func getLoggedInUserSeq()-> Int{
       return getValueInt(key: PreferencesUtil.LOGGED_IN_USER_SEQ_KEY)
    }
    
    func setLoggedInCompanySeq(companySeq:Int){
        setValue(key: PreferencesUtil.LOGGED_IN_COMPANY_SEQ_KEY,value: companySeq)
    }
    
    func getLoggedInCompanySeq()-> Int{
        return getValueInt(key: PreferencesUtil.LOGGED_IN_COMPANY_SEQ_KEY)
    }
    
    func getLoggedInUserName()->String?{
        let userSeq = getLoggedInUserSeq()
        let user = UserMgr.sharedInstance.getUserByUserSeq(userSeq:userSeq)
        return user?.username
    }
    
    func getValueInt(key: String)->Int{
        let userDefaults = UserDefaults.standard
        return userDefaults.integer(forKey:key)
    }
    
    func setValue(key: String,value:Any){
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(value, forKey: key)
    }
    func getValue(key: String)->String?{
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey:key)
    }
    
    func isNotificationState()->Bool{
        return getValueBool(key: PreferencesUtil.NOTIFICATION_STATE);
    }
    
    func setNotificationState(flag:Bool){
        setValue(key: PreferencesUtil.NOTIFICATION_STATE,value: flag);
    }
    
    func isAppActive()->Bool{
        return getValueBool(key: PreferencesUtil.APP_ACTIVE_STATE);
    }
    
    func setAppActive(flag:Bool){
        setValue(key: PreferencesUtil.APP_ACTIVE_STATE,value: flag);
    }
    
    func setNotificationData(entityType:String,entitySeq:String,fromUserName:String,lpSeq:String){
        setValue(key: PreferencesUtil.NOTIFICATION_ENTITY_SEQ, value: entitySeq)
        setValue(key: PreferencesUtil.NOTIFICATION_ENTITY_TYPE, value: entityType)
        setValue(key: PreferencesUtil.FROM_USER_NAME, value: fromUserName)
        setValue(key: PreferencesUtil.LP_SEQ, value: lpSeq)
    }
    
    func getNotificationData()->[String: String]{
        let entityType = getValue(key: PreferencesUtil.NOTIFICATION_ENTITY_TYPE)!
        let entitySeq = getValue(key: PreferencesUtil.NOTIFICATION_ENTITY_SEQ)!
        let fromUserName = getValue(key: PreferencesUtil.FROM_USER_NAME)!
        let lpSeq = getValue(key: PreferencesUtil.LP_SEQ)!
        var notificationData:[String:String] = [:]
        notificationData["entityType"] = entityType
        notificationData["entitySeq"] = entitySeq
        notificationData["fromUserName"] = fromUserName
        notificationData["lpSeq"] = lpSeq
        return notificationData
    }
    
    func getValueBool(key: String)->Bool{
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey:key)
    }
    
    
    func resetNotificationData(){
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if(key == PreferencesUtil.NOTIFICATION_ENTITY_TYPE || key == PreferencesUtil.NOTIFICATION_ENTITY_SEQ || key == PreferencesUtil.NOTIFICATION_STATE || key == PreferencesUtil.NOTIFICATION_ENTITY_SEQ ){
                defaults.removeObject(forKey: key)
            }
            UIApplication.shared.applicationIconBadgeNumber = 0
            setValue(key: PreferencesUtil.APP_ACTIVE_STATE,value: false);
        }
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            //if(key == PreferencesUtil.LOGGED_IN_USER_SEQ_KEY || key == PreferencesUtil.LOGGED_IN_COMPANY_SEQ_KEY){
                defaults.removeObject(forKey: key)
           // }
        }
    }
}
