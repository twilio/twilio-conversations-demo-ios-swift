//
//  PersistentMessageDataItem+CoreDataClass.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
//

import Foundation
import CoreData
import TwilioConversationsClient

@objc(PersistentMessageDataItem)
public class PersistentMessageDataItem: NSManagedObject {

    convenience init(with messageDataItem: MessageDataItem,
                     insertInto context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.init(context: context)
        setup(with: messageDataItem)
    }

    func setup(with messageDataItem: MessageDataItem) {
        self.sid = messageDataItem.sid
        self.author = messageDataItem.author
        self.body = messageDataItem.body
        self.conversationSid = messageDataItem.conversationSid
        self.dateCreated = Date(timeIntervalSince1970: messageDataItem.dateCreated)
        self.dateUpdated = Date()
        self.direction = Int64(messageDataItem.direction.rawValue)
        self.index = Int64(messageDataItem.index)
        self.sendStatus = Int64(messageDataItem.sendStatus.rawValue)
        self.type = Int64(messageDataItem.type.rawValue)
        self.uuid = messageDataItem.uuid
        self.mediaSid = messageDataItem.mediaSid

        if let downloadStatus = messageDataItem.mediaStatus {
            self.mediaDownloadStatus = NSNumber(value: downloadStatus.rawValue)
        }

        //Handle media url
        if let mediaProperties = messageDataItem.mediaProperties  {
            self.bytesUploaded = mediaProperties.uploadedSize
            self.totalBytes = mediaProperties.messageSize
            self.mediaURL = mediaProperties.mediaURL?.absoluteString
        }
        
        // Clean up the old reactions
        if let oldReactions = self.reactions {
            self.removeFromReactions(oldReactions)
            for r in oldReactions {
                managedObjectContext?.delete(r)
            }
        }

        let reactionDictionary = messageDataItem.reactions.reactionDict
        for (reactionType, participants) in reactionDictionary {
            for participantIdentity in participants {
                let findParticipantByIdRequest: NSFetchRequest<PersistentParticipantDataItem> = PersistentParticipantDataItem.fetchRequest()
                findParticipantByIdRequest.predicate = NSPredicate(format: "identity = %@", participantIdentity)
                findParticipantByIdRequest.sortDescriptors = []
                guard let participantWhoReacted  = ObservableFetchRequestResult(with: findParticipantByIdRequest).value?.first else {
                    break
                }
                let reaction = PersistentMessageReactionDataItem(withReaction: reactionType.rawValue, forParticipant: participantWhoReacted, onMessage:self)
                self.addToReactions(reaction)
            }
        }
    }

    func getMessageDataItem() -> MessageDataItem {
        var itemReactions = MessageReactionsModel()
        if let storeReactions = self.reactions {
            for r in storeReactions {
                guard let reactionType = ReactionType(rawValue: r.reactionType),
                      let participantIdendty = r.participant?.identity else {
                    break
                }
                itemReactions.tooggleReaction(recation: reactionType, forParticipant: participantIdendty)
            }
        }
        
        let mediaProperties = MediaMessageProperties(
            mediaURL: URL(string: self.mediaURL ?? ""),
            messageSize: Int(self.totalBytes),
            uploadedSize: Int(self.bytesUploaded)
        )

        var mediaStatus: MediaStatus?
        if let status = mediaDownloadStatus  {
            mediaStatus = MediaStatus(rawValue: status.intValue)
        }

        
        return MessageDataItem(
            sid: sid,
            uuid: uuid!,
            index: UInt(index),
            direction: MessageDirection(rawValue: Int(direction))!,
            author: author!,
            body: body,
            dateCreated:
            dateCreated!.timeIntervalSince1970,
            sendStatus: MessageSendStatus(rawValue: Int(sendStatus))!,
            conversationSid: conversationSid!,
            type: TCHMessageType(rawValue: TCHMessageType.RawValue(type))!,
            mediaSid: mediaSid,
            reactions: itemReactions,
            mediaProperties: mediaProperties,
            mediaStatus: mediaStatus
        )
    }
}
