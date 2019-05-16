//
//  PersistentConversationDataItem+CoreDataProperties.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import CoreData
import TwilioConversationsClient


extension PersistentConversationDataItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersistentConversationDataItem> {
        return NSFetchRequest<PersistentConversationDataItem>(entityName: "PersistentConversationDataItem")
    }

    @NSManaged public var attributes: String?
    @NSManaged public var createdBy: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateUpdated: Date?
    @NSManaged public var friendlyName: String?
    @NSManaged public var lastMessageDate: Date?
    @NSManaged public var participantsCount: Int64
    @NSManaged public var messagesCount: Int64
    @NSManaged public var notificationLevel: Int64
    @NSManaged public var sid: String?
    @NSManaged public var type: Int64
    @NSManaged public var unreadMessagesCount: Int64
    @NSManaged public var uniqueName: String?

    func getConversationDataItem() -> ConversationDataItem {
        return ConversationDataItem(sid: sid ?? "",
                               friendlyName: friendlyName ?? "",
                               uniqueName: uniqueName ?? "",
                               attributes: attributes?.toDictionary() ?? [:],
                               dateUpdated: dateUpdated?.timeIntervalSince1970 ?? 0,
                               dateCreated: dateCreated?.timeIntervalSince1970,
                               createdBy: createdBy ?? "",
                               participantsCount: Int(participantsCount),
                               messagesCount: Int(messagesCount),
                               unreadMessagesCount: Int(unreadMessagesCount),
                               notificationLevel: TCHConversationNotificationLevel(rawValue: Int(notificationLevel)) ?? .default,
                               lastMessageDate: lastMessageDate?.timeIntervalSince1970 ?? 0
        )
    }
}
