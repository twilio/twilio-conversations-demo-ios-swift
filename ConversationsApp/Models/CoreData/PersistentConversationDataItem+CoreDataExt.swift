//
//  PersistentConversationDataItem+CoreDataExt.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import CoreData
import TwilioConversationsClient

extension PersistentConversationDataItem {

    var title: String {
        get {
            self.friendlyName ?? self.uniqueName ?? self.sid ?? "<unknown>"
        }
    }
    
    public var deliveryStatus: String {
        get {
            "checkmark"
        }
    }
    
    public var lastMessageContentIcon: String {
        get {
            if (lastMessageContentType == .image){
                return "photo.fill"
            } else if (lastMessageContentType == .file){
                return "paperclip"
            } else {
                return ""
            }
        }
    }
    
    var lastMessageContentType: MessageType {
        get {
            if (self.lastMessageType == MessageType.image.rawValue) {
                return MessageType.image
            } else if (self.lastMessageType == MessageType.file.rawValue) {
                return MessageType.file
            } else {
                return MessageType.text
            }
        }
    }
    
    var lastMessageContentAuthor: String {
        get {
            return self.lastMessageAuthor ?? ""
        }
    }
    
    enum MessageType : String {
        case text = "text"
        case image = "image"
        case file = "file"
    }
    
    static let formatter = RelativeDateTimeFormatter()

    public var lastMessageDateFormatted: String {
        get {
            guard let date = self.lastMessageDate else {
                return ""
            }

            if Calendar.current.isDateInToday(date) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                return dateFormatter.string(from: date)
            }

            return PersistentConversationDataItem.formatter.localizedString(for: date, relativeTo: Date.now) // MARK: ios 15+
        }
    }
    
    static func from(conversation: TCHConversation, inContext context: NSManagedObjectContext) -> PersistentConversationDataItem? {
        guard let conversationSid = conversation.sid else {
            return nil
        }
        
        // update/import participants associated with this conversation
        
        conversation.participants().forEach { participant in
            if let item = PersistentParticipantDataItem.from(participant: participant, inConversation: conversation, inContext: context) {
                item.update(with: participant, withConversationSid: conversationSid, inContext: context)
            } else {
                context.performAndWait {
                    let item = PersistentParticipantDataItem.from(participant: participant, inConversation: conversation, inContext: context)
                    item?.update(with: participant, withConversationSid: conversationSid, inContext: context)
                }
            }
        }
        
        if let item = PersistentConversationDataItem.from(sid: conversationSid, inContext: context) {
            item.update(with: conversation, inContext: context)
            return item
        } else {
            return context.performAndWait {
                let item = PersistentConversationDataItem(context: context)
                item.update(with: conversation, inContext: context)
                return item
            }
        }
    }

    func update(with conversation: TCHConversation, inContext context: NSManagedObjectContext) {
        context.perform {
            self.sid = conversation.sid
            self.attributes = conversation.attributes()?.string
            self.muted = conversation.notificationLevel == .muted
            self.dateCreated = conversation.dateCreatedAsDate
            
            if let friendlyName = conversation.friendlyName {
                self.friendlyName = friendlyName
            }
            if let uniqueName = conversation.uniqueName {
                self.uniqueName = uniqueName
            }
            if let dateUpdated = conversation.dateUpdatedAsDate {
                self.dateUpdated = dateUpdated
            }
            if let createdBy = conversation.createdBy {
                self.createdBy = createdBy
            }
            if let lastMessageDate = conversation.lastMessageDate {
                self.lastMessageDate = lastMessageDate
            }
            if let lastReadIndex = conversation.lastReadMessageIndex?.int64Value {
                self.lastReadMessageIndex = lastReadIndex
            }
        }
        

        DispatchQueue.global(qos: .background).async {
            conversation.getParticipantsCount { result, count in
                guard result.isSuccessful else {
                    return
                }
                context.perform {
                    self.participantsCount = Int64(count)
                }
            }

            conversation.getUnreadMessagesCount { result, count in
                guard result.isSuccessful,
                      let count = count else {
                    return
                }
                context.perform {
                    self.unreadMessagesCount = Int64(truncating: count)
                }
            }

            conversation.getMessagesCount { result, count in
                guard result.isSuccessful else {
                    return
                }
                context.perform {
                    self.messagesCount = Int64(count)
                }
            }
            
            conversation.getLastMessages(withCount: 1) { result, messages in
                guard result.isSuccessful, let messages = messages, !messages.isEmpty else {
                    return
                }
                context.perform {
                    
                    if let lastMessage = messages.first {
                        if lastMessage.attachedMedia.count == 0 {
                            self.lastMessagePreview = lastMessage.body
                            self.lastMessageType = MessageType.text.rawValue
                            //For Demo Apps v1 we'll assume that mediaAttachment for a message only has 1 attachment.
                        } else if (["image/jpeg", "image/png"].contains(lastMessage.attachedMedia.first?.contentType)) {
                            self.lastMessageType = MessageType.image.rawValue
                        } else {
                            self.lastMessageType = MessageType.file.rawValue
                        }
                        self.lastMessageSid = lastMessage.sid
                        self.lastMessageAuthor = lastMessage.author
                        let _: PersistentMessageDataItem? = PersistentMessageDataItem.from(sid: lastMessage.sid!, inContext: context)
                    }
                }
            }
        }
    }

    static func from(sid: String, inContext context: NSManagedObjectContext) -> PersistentConversationDataItem? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let fetchRequest = PersistentConversationDataItem.fetchRequest()
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

    static func deleteConversationsUnchecked(_ conversationSids: [String], inContext context: NSManagedObjectContext) {
        if conversationSids.isEmpty {
            return
        }

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentConversationDataItem")
            let predicates: [NSPredicate] = conversationSids.compactMap { NSPredicate(format: "sid = %@", $0) }
            fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)

            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! context.executeAndMergeChanges(using: deleteRequest)
        }
    }

    static func deleteAllUnchecked(inContext context: NSManagedObjectContext) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentConversationDataItem")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! context.executeAndMergeChanges(using: deleteRequest)
    }
}

/// For view testing
extension PersistentConversationDataItem {
    struct Decode: Decodable, Hashable {
        var sid: String
        var attributes: String?
        var muted: Bool
        var dateCreated: TimeInterval
        var dateUpdated: TimeInterval
        var friendlyName: String
        var uniqueName: String?
        var createdBy: String
        var lastMessageDate: TimeInterval
        var participantsCount: Int64
        var unreadMessagesCount: Int64
        var messagesCount: Int64
        var lastMessagePreview: String?
        
        func conversation(inContext context: NSManagedObjectContext) -> PersistentConversationDataItem {
            let item = PersistentConversationDataItem(context: context)
            item.sid = self.sid
            item.attributes = self.attributes
            item.muted = self.muted
            item.dateCreated = Date(timeIntervalSince1970: self.dateCreated)
            item.friendlyName = self.friendlyName
            item.uniqueName = self.uniqueName
            item.dateUpdated = Date(timeIntervalSince1970: self.dateUpdated)
            item.createdBy = self.createdBy
            item.lastMessageDate = Date(timeIntervalSince1970: self.lastMessageDate)
            item.participantsCount = self.participantsCount
            item.unreadMessagesCount = self.unreadMessagesCount
            item.messagesCount = self.messagesCount
            item.lastMessagePreview = self.lastMessagePreview
            context.performAndWait {
                try! context.save()
            }
            return item
        }
    }
}
