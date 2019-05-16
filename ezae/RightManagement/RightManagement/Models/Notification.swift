//
//  Notification.swift
//  RightManagement
//
//  Created by Munish Sethi on 11/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import Foundation
class NotificationObj{
    var seq:Int
    var title:String
    var notificationType:String
    var isread:Bool
    var entitySeq:Int
    
    init(seq:Int,title:String,notificationType:String,isRead:Bool,entitySeq:Int){
        self.seq = seq
        self.title = title
        self.notificationType = notificationType
        self.isread = isRead
        self.entitySeq = entitySeq
    }
    
}
