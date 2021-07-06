//
//  TCHConversation+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
import Foundation
import TwilioConversationsClient

extension TCHConversation {

    func updateStats(conversationDao: ConversationDAO) {
        DispatchQueue.global(qos: .background).async {
            guard let sid = self.sid else {
                return
            }

            if var storedConversation = conversationDao.getConversationDataItem(sid: sid) {
                storedConversation.dateCreated = self.dateCreatedAsDate?.timeIntervalSince1970
                storedConversation.notificationLevel = self.notificationLevel
                if let dateUpdated = self.dateUpdatedAsDate {
                    storedConversation.dateUpdated = dateUpdated.timeIntervalSince1970
                }
                if let lastMessageDate = self.lastMessageDate {
                    storedConversation.lastMessageDate = lastMessageDate.timeIntervalSince1970
                }
                if let friendlyName = self.friendlyName {
                    storedConversation.friendlyName = friendlyName
                }
                if let uniqueName = self.uniqueName {
                    storedConversation.uniqueName = uniqueName
                }
                if let createdBy = self.createdBy {
                    storedConversation.createdBy = createdBy
                }
                if let lastMessageDate = self.lastMessageDate {
                    storedConversation.lastMessageDate = lastMessageDate.timeIntervalSince1970
                }
                conversationDao.upsert([storedConversation])
            }

            self.getParticipantsCount { result, count in
                guard result.isSuccessful, var storedConversation = conversationDao.getConversationDataItem(sid: sid) else {
                    return
                }
                storedConversation.participantsCount = Int(count)
                DispatchQueue.global().async {
                    conversationDao.upsert([storedConversation])
                }
            }

            self.getUnreadMessagesCount { result, count in
                guard result.isSuccessful,
                      var storedConversation = conversationDao.getConversationDataItem(sid: sid),
                      let count = count else {
                    return
                }
                storedConversation.unreadMessagesCount = count.intValue
                DispatchQueue.global().async {
                    conversationDao.upsert([storedConversation])
                }
            }

            self.getMessagesCount { result, count in
                guard result.isSuccessful, var storedConversation = conversationDao.getConversationDataItem(sid: sid) else {
                    return
                }
                storedConversation.messagesCount = Int(count)
                DispatchQueue.global().async {
                    conversationDao.upsert([storedConversation])
                }
            }
        }
    }
}
