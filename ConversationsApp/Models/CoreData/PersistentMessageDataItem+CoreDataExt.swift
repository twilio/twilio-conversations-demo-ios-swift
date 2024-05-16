//
//  PersistentMessageDataItem+CoreDataExt.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData
import TwilioConversationsClient

extension PersistentMessageDataItem {

    var reactions: ReactionsDict {
        get {
            return ReactionsDict.from(attributes: self.attributes)
        }
        set {
            guard let attributes = newValue.toAttributes() else {
                return
            }
            NSLog("Serialized attributes to \(attributes)")
            self.attributes = attributes
        }
    }
    
    // Message attributes are stored as string. AttributesDictionary provides them as dictionary to send it back the SDK.
    var attributesDictionary: [String: Any]? {
        get {
            if let attributes = self.attributes, let data = attributes.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {
                    print(error.localizedDescription)
                }
            }
            return nil
        }
    }

    // MARK: Conversions

    /// Construct CoreData object from Conversations objects.
    static func from(message: TCHMessage, inConversation conversation: TCHConversation, withDirection direction: MessageDirection, inContext context: NSManagedObjectContext) -> PersistentMessageDataItem? {
        guard let messageSid = message.sid,
              let conversationSid = conversation.sid,
              let participantSid = message.participantSid else {
            return nil
        }

        if let item = PersistentMessageDataItem.from(sid: messageSid, inContext: context) {
            item.update(with: message, forConversationSid: conversationSid, withDirection: direction, inContext: context)
            return item
        } else {
            return context.performAndWait {
                let item = PersistentMessageDataItem(context: context)
                item.update(with: message, forConversationSid: conversationSid, withDirection: direction, inContext: context)
                return item
            }
        }
    }

    func update(with message: TCHMessage, forConversationSid sid: String, withDirection direction: MessageDirection, inContext context: NSManagedObjectContext) {

        context.perform {
            self.messageIndex = Int64(truncating: message.index!)
            self.conversationSid = sid
            self.author = message.author
            self.body = message.body
            self.dateCreated = message.dateCreatedAsDate
            self.dateUpdated = message.dateUpdatedAsDate
            self.direction = Int16(direction.rawValue)
            self.participantSid = message.participantSid
            self.sid = message.sid
            if self.uuid == nil {
                self.uuid = UUID()
            }

            let mediaItems = NSMutableSet()
            for media in message.attachedMedia {
                if let mediaDataItem = PersistentMediaDataItem.from(media: media, forConversationSid: sid, inContext: context) {
                    mediaItems.add(mediaDataItem)
                }
            }
            self.attachedMedia = mediaItems
            
            if let attrs = message.attributes(), attrs.isDictionary {
                do {
                    let data = try JSONSerialization.data(withJSONObject: attrs.dictionary as Any, options: [])
                    self.attributes = String(data: data, encoding: .utf8)
                } catch {
                    NSLog("Failed to serialize attributes")
                    self.attributes = "{}"
                }
            } else {
                NSLog("Attributes were not a dictionary")
                self.attributes = "{}"
            }
        }
    }

    static func from(sid: String, inContext context: NSManagedObjectContext) -> PersistentMessageDataItem? {
        let fetchRequest = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sid = %@", sid)

        do {
            let result = try context.performAndWait {
                try context.fetch(fetchRequest)
            }
            return result.first
        } catch {
            return nil
        }
    }

    static func deleteMessagesUnchecked(_ messageSids: [String], inContext context: NSManagedObjectContext) {
        if messageSids.isEmpty {
            return
        }

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentMessageDataItem")
            let predicates: [NSPredicate] = messageSids.compactMap { NSPredicate(format: "sid = %@", $0) }
            fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! context.executeAndMergeChanges(using: deleteRequest)
        }
    }
    
    static func deleteAllMessagesByConversationSid(_ conversationSids: [String], inContext context: NSManagedObjectContext) {
        if conversationSids.isEmpty {
            return
        }

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentMessageDataItem")
            let predicates: [NSPredicate] = conversationSids.compactMap { NSPredicate(format: "conversationSid = %@", $0) }
            fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! context.executeAndMergeChanges(using: deleteRequest)
        }
    }
    
    static func deleteAllUnchecked(inContext context: NSManagedObjectContext) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentMessageDataItem")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! context.executeAndMergeChanges(using: deleteRequest)
    }
}

/// For view testing
/// https://www.swiftbysundell.com/basics/codable/
extension PersistentMessageDataItem {
    struct Decode: Decodable {
        var sid: String
        var uuid: UUID
        var index: Int64
        var direction: Int16
        var author: String
        var body: String
        var dateCreated: TimeInterval
        var dateUpdated: TimeInterval
        var attachedMedia: String?
        var attributes: String?

        func message(inContext context: NSManagedObjectContext) -> PersistentMessageDataItem {
            let item = PersistentMessageDataItem(context: context)
            item.sid = self.sid
            item.uuid = self.uuid
            item.messageIndex = self.index
            item.direction = self.direction
            item.author = self.author
            item.body = self.body
            item.attributes = self.attributes
            item.dateCreated = Date(timeIntervalSince1970: self.dateCreated)
            item.dateUpdated = Date(timeIntervalSince1970: self.dateUpdated)
            let mediaItems = NSMutableSet()
            //For Demo Apps v1 we'll assume that mediaAttachment for a message only has 1 attachment.
            if let attachedMedia = self.attachedMedia, let data = attachedMedia.data(using: .utf8) {
                do {
                    let media = try JSONDecoder().decode(PersistentMediaDataItem.Decode.self, from: data)
                    let mediaDataItem = PersistentMediaDataItem(context: context)
                    mediaDataItem.sid = media.sid
                    mediaDataItem.contentType = media.contentType
                    mediaDataItem.size = media.size
                    mediaDataItem.filename = media.filename
                    mediaDataItem.category = media.category
                    mediaItems.add(mediaDataItem)
                    item.attachedMedia = mediaItems
                } catch {
                    print(error.localizedDescription)
                }
            }
            item.conversationSid = ""
            item.participantSid = ""
            return item
        }
    }
}
