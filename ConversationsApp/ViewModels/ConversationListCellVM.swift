//
//  ConversationListCellVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

class ConversationListCellViewModel {

    // MARK: Properties

    weak var delegate: ConversationListActionListener?
    var sid: String
    var uniqueName: String
    var friendlyName: String
    var participantsCount: String?
    var dateCreated: String?
    var dateUpdated: String
    var unreadMessageCount: Int
    var dateFormatter = DateFormatter()
    var notificationLevel: TCHConversationNotificationLevel
    var lastMessageDate: String
    var userInteractionState = ConversationCellUserInteractionState()

    // MARK: Intialization

    init?(item: ConversationDataItem) {
        sid = item.sid
        uniqueName = item.uniqueName
        friendlyName = item.friendlyName
        unreadMessageCount = item.unreadMessagesCount
        notificationLevel = item.notificationLevel

        let format = NSLocalizedString("number_of_participants", comment: "Number of participants in a conversations conversation")
        self.participantsCount = String.localizedStringWithFormat(format, item.participantsCount )

        if let creationDate = item.dateCreated {
            dateCreated = dateFormatter.createDateString(from: creationDate, format: "dd-MM-yyyy")
        }
        lastMessageDate = dateFormatter.createDateString(from: item.lastMessageDate, format: "HH:mm")
        dateUpdated = dateFormatter.createDateString(from: item.dateUpdated, format: "HH:mm")
    }
}

struct ConversationCellUserInteractionState {

    var isJoining = Observable<Bool>(false)
    var isChangingNotificationLevel = false
    var isDestroyingConversation = false
    var isAddingParticipant = false
}

extension ConversationListCellViewModel: CustomDebugStringConvertible {

    var debugDescription: String {
        "sid: \(sid), fn: \(friendlyName), un: \(uniqueName), lmd: \(lastMessageDate), du: \(dateUpdated), dc: \(dateCreated ?? "nil")"
    }
}
