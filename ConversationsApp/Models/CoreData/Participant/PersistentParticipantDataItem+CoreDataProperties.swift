//
//  PersistentParticipantDataItem+CoreDataProperties.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension PersistentParticipantDataItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentParticipantDataItem> {
        return NSFetchRequest<PersistentParticipantDataItem>(entityName: "PersistentParticipantDataItem")
    }

    @NSManaged public var sid: String
    @NSManaged public var conversationSid: String
    @NSManaged public var identity: String
    @NSManaged public var type: Int16
    @NSManaged public var attributes: String?
    @NSManaged public var lastReadMessage: Int64
    @NSManaged public var isTyping: Bool
}
