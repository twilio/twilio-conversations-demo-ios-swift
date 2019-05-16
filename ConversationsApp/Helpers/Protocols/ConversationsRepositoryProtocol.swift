//
//  ConversationsRepository.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol ConversationsRepositoryProtocol: AnyObject {

    // MARK: - Properties
    var conversationsProvider: ConversationsProvider { get }
    var localCacheProvider: LocalCacheProvider { get }
    var listener: ConversationsRepositoryListenerProtocol? { get set }

    // MARK: - Conversations methods
    func getConversationList() -> RepositoryResultHandle<PersistentConversationDataItem>
    func clearConversationList()
    func getConversationWithSid(_ sid: String) -> RepositoryResultHandle<PersistentConversationDataItem>
    func getConversationSidToNavigateTo() -> String?

    // MARK: - Message methods
    func getMessages(for conversationSid: String, by pageSize: UInt) -> RepositoryResultHandle<PersistentMessageDataItem>
    func getMessageWithUuid(_ uuid: String) -> RepositoryResultHandle<PersistentMessageDataItem>
    func insertMessages(_ messages: [MessageDataItem], for conversationSid: String)
    func updateMessages(_ messages: [MessageDataItem])
    func deleteMessagesWithSids(_ messageSids: [String])
    func getMessageWithSid(_ sid: String) -> MessageDataItem?
    func getMessageWithIndex(messageIndex: NSNumber, onConversation conversationSid: String) -> MessageDataItem?

    // MARK: - Participants methods
    func getTypingParticipants(inConversation conversationSid: String) -> RepositoryResultHandle<PersistentParticipantDataItem>

}
