//
//  PersistentParticipantDataItem+CoreDataExt.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData
import TwilioConversationsClient

extension PersistentParticipantDataItem {

    static func from(participant: TCHParticipant, inConversation conversation: TCHConversation, inContext context: NSManagedObjectContext) -> PersistentParticipantDataItem? {
        guard let conversationSid = conversation.sid,
              let participantSid = participant.sid else {
            return nil
        }
        if let item = PersistentParticipantDataItem.from(sid: participantSid, inContext: context) {
            item.update(with: participant, withConversationSid: conversationSid, inContext: context)
            return item
        } else {
            return context.performAndWait { // MARK: ios 15+
                let item = PersistentParticipantDataItem(context: context)
                item.update(with: participant, withConversationSid: conversationSid, inContext: context)
                return item
            }
        }
    }

    func update(with participant: TCHParticipant, withConversationSid conversationSid: String, inContext context: NSManagedObjectContext) {
        context.perform {
            self.sid = participant.sid
            self.conversationSid = conversationSid
            self.identity = participant.identity
            // TODO: Properly convert this channelType to a string, currently it is just a Swift enum and the channel string is hidden for Swift.
            self.channel = String(describing: participant.channelType)

            if let attributes = participant.attributes() {
                if attributes.isDictionary, let dictionary = attributes.dictionary {
                    do {
                        let json = try JSONSerialization.data(withJSONObject: dictionary)
                        let jsonString = String.init(data: json, encoding: String.Encoding.utf8)
                        self.attributes = jsonString
                    } catch {
                        print(error)
                    }
                }
            }
            
            self.lastReadMessage = participant.lastReadMessageIndex?.int64Value ?? -1
        }
    }

    static func from(sid: String, inContext context: NSManagedObjectContext) -> PersistentParticipantDataItem? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let fetchRequest = PersistentParticipantDataItem.fetchRequest()
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

    static func deleteParticipants(_ participantSids: [String], inContext context: NSManagedObjectContext) {
        if participantSids.isEmpty {
            return
        }

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentParticipantDataItem")
            let predicates: [NSPredicate] = participantSids.compactMap { NSPredicate(format: "sid = %@", $0) }
            fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
            
            let result = try? context.fetch(fetchRequest)
            let participants = result as! [PersistentParticipantDataItem]
            
            for participant in participants {
                context.delete(participant)
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to save context after deleting participants")
            }
        }
    }
    
    static func deleteAllParticipantsByConversationSid(_ conversationSids: [String], inContext context: NSManagedObjectContext) {
        if conversationSids.isEmpty {
            return
        }

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentParticipantDataItem")
            let predicates: [NSPredicate] = conversationSids.compactMap { NSPredicate(format: "conversationSid = %@", $0) }
            fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! context.executeAndMergeChanges(using: deleteRequest)
        }
    }
    
    static func deleteAllUnchecked(inContext context: NSManagedObjectContext) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentParticipantDataItem")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! context.executeAndMergeChanges(using: deleteRequest)
    }
        
    func getDisplayName() -> String {
        if let identity = identity, !identity.isEmpty {
            return identity
        } else {
            if let json = attributes?.data(using: String.Encoding.utf8) {
                do {
                    let attributes = try JSONSerialization.jsonObject(with: json, options: .mutableContainers)
                    
                    if let attributes = attributes as? [String: Any],
                       let friendlyName = attributes["friendlyName"] as? String {
                        return friendlyName
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        return ""
    }
}
