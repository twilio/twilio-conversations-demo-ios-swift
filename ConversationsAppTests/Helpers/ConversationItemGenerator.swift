//
//  ConversationItemGenerator.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import XCTest
import TwilioConversationsClient
@testable import ConversationsApp

class ConversationItemGenerator {

    static func createDiverseConversationList() -> [ConversationDataItem] {
        // Private invited
        let conversation0 = ConversationDataItem(sid: "0", friendlyName: "0", uniqueName: "0", attributes: [:], dateUpdated: 0, dateCreated: 0,
                                                 createdBy: "0", participantsCount: 1, messagesCount: 0, unreadMessagesCount: 0,
                                                 notificationLevel: .muted, lastMessageDate: 0)

        // Private joined
        let conversation1 = ConversationDataItem(sid: "1", friendlyName: "1", uniqueName: "1", attributes: [:], dateUpdated: 1, dateCreated: 1,
                                                 createdBy: "1", participantsCount: 1, messagesCount: 1, unreadMessagesCount: 1,
                                                 notificationLevel: .default, lastMessageDate: 1)
        // Public invited
        let conversation2 = ConversationDataItem(sid: "2", friendlyName: "2", uniqueName: "2", attributes: [:], dateUpdated: 2, dateCreated: 2,
                                                 createdBy: "2", participantsCount: 2, messagesCount: 2, unreadMessagesCount: 2,
                                                 notificationLevel: .default, lastMessageDate: 2)

        // Public joined
        let conversation3 = ConversationDataItem(sid: "3", friendlyName: "3", uniqueName: "3", attributes: [:], dateUpdated: 3, dateCreated: 3,
                                                 createdBy: "3", participantsCount: 3, messagesCount: 3, unreadMessagesCount: 3,
                                                 notificationLevel: .muted, lastMessageDate: 3)

        // Public not joined
        let conversation4 = ConversationDataItem(sid: "4", friendlyName: "4", uniqueName: "4", attributes: [:], dateUpdated: 4, dateCreated: 4,
                                                 createdBy: "4", participantsCount: 4, messagesCount: 4, unreadMessagesCount: 4,
                                                 notificationLevel: .default, lastMessageDate: 4)

        // Private not joined
        let conversation5 = ConversationDataItem(sid: "5", friendlyName: "5", uniqueName: "5", attributes: [:], dateUpdated: 5, dateCreated: 5,
                                                 createdBy: "5", participantsCount: 5, messagesCount: 5, unreadMessagesCount: 5,
                                                 notificationLevel: .default, lastMessageDate: 5)

        return [conversation0, conversation1, conversation2, conversation3, conversation4, conversation5]
    }
}
