//
//  Message.swift
//  Whatsapp
//
//  Created by Rafael Castro on 6/16/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

import UIKit

enum MessageStatus {
    case Sending
    case Sent
    case Received
    case Read
    case Failed
}

enum MessageSender {
    case Myself
    case Someone
}

class MessageDetail:NSObject {
    var sender:MessageSender = .Myself
    var status:MessageStatus = .Sending
    var identifier:String = ""
    var chatId:String = ""
    var text:String = ""
    var date:NSDate = NSDate()
    var height:CGFloat = 44
    var username:String = ""
    func messageFromDictionary(dictionary:NSDictionary) -> MessageDetail {
        let message = MessageDetail()
        message.text = dictionary["text"] as! String
        message.identifier = dictionary["messageId"] as! String
        message.status = dictionary["status"] as! MessageStatus
        
        let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        //Date in UTC
        let inputTimeZone = NSTimeZone(abbreviation: "UTC")
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.timeZone = inputTimeZone as TimeZone!
        inputDateFormatter.dateFormat = dateFormat
        let date = inputDateFormatter.date(from: dictionary["sent"] as! String)
        
        //Convert time in UTC to Local TimeZone
        let outputTimeZone = NSTimeZone.local
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.timeZone = outputTimeZone
        outputDateFormatter.dateFormat = dateFormat
        let outputString = outputDateFormatter.string(from: date!)
        
        message.date = outputDateFormatter.date(from: outputString)! as NSDate
        
        return message
    }
}
