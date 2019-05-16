//
//  MessageGateway.swift
//  Whatsapp
//
//  Created by Rafael Castro on 7/4/15. / Swift Version by Breno Oliveira on 02/18/16.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

@objc protocol MessageGatewayDelegate:NSObjectProtocol {
    func gatewayDidUpdateStatusForMessage(message:MessageDetail)
    func gatewayDidReceiveMessages(array:[MessageDetail])
}


class MessageGateway:NSObject {
    var delegate:MessageGatewayDelegate!
    var chat:Chat!
    var messagesToSend:NSMutableArray = NSMutableArray()
    
    
    func loadOldMessages() {
        let array = LocalStorage.sharedInstance.queryMessagesForChatId(chatId: self.chat.identifier)
        if array == nil {
            return
        }

        self.delegate?.gatewayDidReceiveMessages(array: array!)
 
        let unreadMessages = self.queryUnreadMessagesInArray(array: array!)
        self.updateStatusToReadInArray(unreadMessages: unreadMessages)
    }
    
    func updateStatusToReadInArray(unreadMessages:[MessageDetail]) {
        var readIds = [String]()
        for message in unreadMessages {
            message.status = .Read
            readIds.append(message.identifier)
        }
        self.chat.numberOfUnreadMessages = 0
        self.sendReadStatusToMessages(messageIds: readIds)
    }
    
    func queryUnreadMessagesInArray(array:[MessageDetail]) -> [MessageDetail] {
        return array.filter({(message:MessageDetail) -> Bool in
            return message.status == .Received
        })
    }
    
    func news() {
        
    }
    func dismiss() {
        self.delegate = nil
    }

    func fakeMessageUpdate(message:MessageDetail) {
        self.perform(#selector(MessageGateway.updateMessageStatus(message:)), with:message, afterDelay:2)
    }
    
    @objc func updateMessageStatus(message:MessageDetail) {
        
        switch message.status {
        case .Sending:
            message.status = .Failed
        case .Failed:
            message.status = .Sent
        case .Sent:
            message.status = .Received
        case .Received:
            message.status = .Read
        default: break
        }
        
//        if self.delegate != nil && self.delegate.responds(to: #selector(MessageGatewayDelegate.gatewayDidUpdateStatusForMessage(message:))) {
//            self.delegate!.gatewayDidUpdateStatusForMessage(message: message)
//        }
        
        //
        // Remove this when connect to your server
        // fake update message
        //
        //if message.status != .Read {
            //self.fakeMessageUpdate(message: message)
        //}
    }

    // MARK - Exchange data with API

    func sendMessage(message:MessageDetail) {
        //
        // Add here your code to send message to your server
        // When you receive the response, you should update message status
        // Now I'm just faking update message
        //
        LocalStorage.sharedInstance.storeMessage(message: message)
        self.fakeMessageUpdate(message: message)
        //TODO
    }
    func sendReadStatusToMessages(messageIds:[String]) {
        if messageIds.count == 0 {
            return
        }
        //TODO
    }
    func sendReceivedStatusToMessages(messageIds:[String]) {
        if messageIds.count == 0 {
            return
        }
        //TODO
    }
    
    static let sharedInstance = MessageGateway()
    private override init() {}
}
