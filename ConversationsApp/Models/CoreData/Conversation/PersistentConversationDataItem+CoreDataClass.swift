//
//  PersistentConversationDataItem+CoreDataClass.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import CoreData

@objc(PersistentConversationDataItem)
public class PersistentConversationDataItem: NSManagedObject {

    convenience init(with conversationDataItem: ConversationDataItem,
                     insertInto context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.init(context: context)
        update(with: conversationDataItem)
    }

    func update(with conversationDataItem: ConversationDataItem) {
        self.sid = conversationDataItem.sid
        self.friendlyName = conversationDataItem.friendlyName
        self.uniqueName = conversationDataItem.uniqueName
        self.dateUpdated = Date(timeIntervalSince1970: conversationDataItem.dateUpdated)
        if let creationDate = conversationDataItem.dateCreated {
            self.dateCreated = Date(timeIntervalSince1970: creationDate)
        }
        self.createdBy = conversationDataItem.createdBy
        self.participantsCount = Int64(conversationDataItem.participantsCount )
        self.messagesCount = Int64(conversationDataItem.messagesCount)
        self.unreadMessagesCount = Int64(conversationDataItem.unreadMessagesCount)

        self.notificationLevel = Int64(conversationDataItem.notificationLevel.rawValue)
        self.lastMessageDate = Date(timeIntervalSince1970: conversationDataItem.lastMessageDate)
    }
}
