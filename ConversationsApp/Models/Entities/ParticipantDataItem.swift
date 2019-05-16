//
//  ParticipantDataItem.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

class ParticipantDataItem {
    
    let sid: String
    let conversationSid: String
    let identity: String
    let type: Int16
    let attributes: String?
    let lastReadMessage: Int64 = 0
    var isTyping: Bool

    init(sid: String, conversationSid: String, identity: String, type: Int16, attributes: String?, isTyping: Bool = false) {
        self.sid = sid
        self.conversationSid = conversationSid
        self.identity = identity
        self.type = Int16(type)
        self.attributes = attributes
        self.isTyping = isTyping
    }
}
