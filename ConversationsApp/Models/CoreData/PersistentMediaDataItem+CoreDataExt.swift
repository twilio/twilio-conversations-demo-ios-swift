//
//  PersistentMediaDataItem+CoreDataExt.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/28/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData
import TwilioConversationsClient

enum MediaCategory: Int {
   case media, body, history
}

extension PersistentMediaDataItem {
    
    /// Construct CoreData object from Message object.
    static func from(media: Media, forConversationSid conversationSid: String, inContext context: NSManagedObjectContext) -> PersistentMediaDataItem? {
        guard !media.sid.isEmpty, let filename = media.filename, !filename.isEmpty, !media.contentType.isEmpty else {
            return nil
        }
                
        if let item = PersistentMediaDataItem.from(sid: media.sid, inContext: context) {
            item.update(with: media, forConversationSid: conversationSid, inContext: context)
            return item
        } else {
            return context.performAndWait {
                let item = PersistentMediaDataItem(context: context)
                item.update(with: media, forConversationSid: conversationSid, inContext: context)
                return item
            }
        }
    }
    
    func update(with media: Media, forConversationSid conversationSid: String, inContext context: NSManagedObjectContext) {
        context.performAndWait {
            self.sid = media.sid
            self.size = Int64(media.size)
            self.filename = media.filename
            self.contentType = media.contentType
            self.category = Int16(media.category.rawValue)
            self.conversationSid = conversationSid
        }
    }
    
    static func from(sid: String, inContext context: NSManagedObjectContext) -> PersistentMediaDataItem? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let fetchRequest = PersistentMediaDataItem.fetchRequest()
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
    
    static func deleteAllMediaItemsByConversationSid(_ conversationSids: [String], inContext context: NSManagedObjectContext) {
        if conversationSids.isEmpty {
            return
        }

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentMediaDataItem")
            let predicates: [NSPredicate] = conversationSids.compactMap { NSPredicate(format: "conversationSid = %@", $0) }
            fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! context.executeAndMergeChanges(using: deleteRequest)
        }
    }
}

/// For view testing

extension PersistentMediaDataItem {

    struct Decode: Decodable {
        var sid: String
        var size: Int64
        var filename: String
        var contentType: String
        var category: Int16
        
        func media(inContext context: NSManagedObjectContext) -> PersistentMediaDataItem {
            let item = PersistentMediaDataItem(context: context)
            item.sid = self.sid
            item.filename = self.filename
            item.contentType = self.contentType
            item.category = self.category
            item.size = self.size
            return item
        }
    }
}
