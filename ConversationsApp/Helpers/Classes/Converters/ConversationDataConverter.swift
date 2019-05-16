//
//  ConversationDataConverter.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ConversationDataConverter: ConversationDataConverterProtocol {

    func convert(conversation: TCHConversation) -> ConversationDataItem? {
        guard let conversationSid = conversation.sid else {
            return nil
        }
        var item = ConversationDataItem(
            sid: conversationSid,
            friendlyName: conversation.friendlyName ?? "",
            uniqueName: conversation.uniqueName ?? "",
            dateUpdated: conversation.dateUpdatedAsDate?.timeIntervalSince1970 ?? 0,
            dateCreated: conversation.dateCreatedAsDate?.timeIntervalSince1970,
            createdBy: conversation.createdBy ?? "")
        item.notificationLevel = conversation.notificationLevel
        item.lastMessageDate = conversation.lastMessageDate?.timeIntervalSince1970 ?? 0
        return item
    }
}
