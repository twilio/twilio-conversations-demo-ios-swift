//
//  PersistentMessageDataItem+CoreDataProperties.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData


extension PersistentMessageDataItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentMessageDataItem> {
        return NSFetchRequest<PersistentMessageDataItem>(entityName: "PersistentMessageDataItem")
    }

    @NSManaged public var author: String?
    @NSManaged public var body: String?
    @NSManaged public var conversationSid: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var direction: Int64
    @NSManaged public var index: Int64
    @NSManaged public var participantSid: String?
    @NSManaged public var sendStatus: Int64
    @NSManaged public var sid: String?
    @NSManaged public var type: Int64
    @NSManaged public var uuid: String?
    @NSManaged public var reactions: Set<PersistentMessageReactionDataItem>?
    @NSManaged public var totalBytes: Int
    @NSManaged public var bytesUploaded: Int
    @NSManaged public var mediaURL: String?
    @NSManaged public var mediaSid: String?
    @NSManaged public var mediaDownloadStatus: NSNumber?
}

// MARK: Generated accessors for reactions

extension PersistentMessageDataItem {

    @objc(addReactionsObject:)
    @NSManaged public func addToReactions(_ value: PersistentMessageReactionDataItem)

    @objc(removeReactionsObject:)
    @NSManaged public func removeFromReactions(_ value: PersistentMessageReactionDataItem)

    @objc(addReactions:)
    @NSManaged public func addToReactions(_ values: Set<PersistentMessageReactionDataItem>)

    @objc(removeReactions:)
    @NSManaged public func removeFromReactions(_ values: Set<PersistentMessageReactionDataItem>)
}
