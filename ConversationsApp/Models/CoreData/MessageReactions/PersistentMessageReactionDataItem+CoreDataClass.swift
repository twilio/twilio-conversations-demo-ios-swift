//
//  PersistentMessageReactionDataItem+CoreDataClass.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PersistentMessageReactionDataItem)
public class PersistentMessageReactionDataItem: NSManagedObject {

    convenience init(
        withReaction reaction: String,
        forParticipant participant: PersistentParticipantDataItem,
        onMessage message: PersistentMessageDataItem,
        insertInto context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.init(context: context)
        self.participant = participant
        self.message = message
        self.reactionType = reaction
    }
}
