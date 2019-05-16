//
//  PersistentMessageReactionDataItem+CoreDataProperties.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData

extension PersistentMessageReactionDataItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentMessageReactionDataItem> {
        return NSFetchRequest<PersistentMessageReactionDataItem>(entityName: "PersistentMessageReactionDataItem")
    }

    @NSManaged public var participant: PersistentParticipantDataItem?
    @NSManaged public var reactionType: String
    @NSManaged public var message: PersistentMessageDataItem
}
