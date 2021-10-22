//
//  PersistentParticipantDataItem+CoreDataClass.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PersistentParticipantDataItem)
public class PersistentParticipantDataItem: NSManagedObject {

    convenience init(with participantDataItem: ParticipantDataItem,
                     insertInto context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.init(context: context)
        update(with: participantDataItem)
    }

    func update(with participantDataItem: ParticipantDataItem) {
        self.sid = participantDataItem.sid
        self.conversationSid = participantDataItem.conversationSid
        self.identity = participantDataItem.identity
        self.type = participantDataItem.type
        self.attributes = participantDataItem.attributes
        self.lastReadMessage = participantDataItem.lastReadMessage
        self.isTyping = participantDataItem.isTyping
    }

    func getParticipantDataItem() -> ParticipantDataItem {
        return ParticipantDataItem(
            sid: self.sid,
            conversationSid: self.conversationSid,
            identity: self.identity,
            type: self.type,
            attributes: self.attributes
        )
    }
}
