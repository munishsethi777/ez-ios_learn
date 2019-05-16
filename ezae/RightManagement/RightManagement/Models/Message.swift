//
//  Message.swift
//  RightManagement
//
//  Created by Munish Sethi on 10/10/17.
//  Copyright © 2017 Munish Sethi. All rights reserved.
//

import UIKit

class Message{
    var messageSeq:Int
    var messageTitle: String
    var messageDescription : String
    var userImageUrl: String
    var date: String
    var chattingUserSeq:Int
    var chattingUserType:String
    var isRead:Bool
    init(seq:Int,messageTitle:String,messageDescription:String,userImageUrl: String,date: String,chattingUserSeq:Int,chattingUserType:String,isRead:Bool){
        self.messageSeq = seq
        self.messageTitle = messageTitle
        self.messageDescription = messageDescription
        self.userImageUrl = userImageUrl
        self.date = date
        self.chattingUserSeq = chattingUserSeq
        self.chattingUserType = chattingUserType
        self.isRead = isRead
    }
}
