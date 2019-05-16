//
//  ConversationDataItem.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

struct ConversationDataItem {

    var sid: String
    var friendlyName: String
    var uniqueName: String
    var attributes: [String: Any]?
    var dateUpdated: TimeInterval
    var dateCreated: TimeInterval?
    var createdBy: String
    var participantsCount: Int = 0
    var messagesCount: Int = 0
    var unreadMessagesCount: Int = 0
    var notificationLevel: TCHConversationNotificationLevel = .default
    var lastMessageDate: TimeInterval = 0
}
