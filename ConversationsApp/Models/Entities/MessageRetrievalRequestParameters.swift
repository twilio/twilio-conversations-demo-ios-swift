//
//  MessageRetrievalRequestParameters.swift
//  ConversationsApp
//
//  MessageRetrievalRequestParameters is used to make sure we retreive the proper message
//  when using the TwilioConversations SDK methods invovling lookup of a message based on its index.
//
//  This messageSid is used for an additional check to confirm we get
//  the message we intened in case of index inconsistencies
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

struct MessageRetrievalRequestParameters {

    let messageIndex: UInt
    let messageSid: String
    let conversationSid: String
}
