//
//  ConversationsRepository.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient
import CoreData

class ConversationsRepository: NSObject, ConversationsRepositoryProtocol {

    // MARK: - Properties
    static let shared = ConversationsRepository()
    private(set) var conversationsProvider: ConversationsProvider
    private(set) var localCacheProvider: LocalCacheProvider
    private var conversationDataConverter: ConversationDataConverterProtocol
    private var messageDataConverter: MessageDataConverterProtocol
    private var participantDataConverter: ParticipantDataConverterProtocol
    weak var listener: ConversationsRepositoryListenerProtocol?

    var devicePushToken: Data?
    var navigateToConversationWithSid: String? {
        didSet {
            if (navigateToConversationWithSid != nil) {
                listener?.pushNotificationTapped()
            }
        }
    }

    // MARK: - Intialization
    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper,
         localCacheProvider: LocalCacheProvider = LocalConversationsCacheProvider.shared,
         conversationsEventPropogator: ConversationsEventPropagator = ConversationsClientWrapper.wrapper,
         messageDataConverter: MessageDataConverterProtocol =  ConversationsDataConverter(),
         conversationDataConverter: ConversationDataConverterProtocol = ConversationDataConverter(),
         participantDataConverter:  ParticipantDataConverterProtocol = ParticipantDataConverter())
    {
        self.conversationsProvider = conversationsProvider
        self.localCacheProvider = localCacheProvider
        self.messageDataConverter = messageDataConverter
        self.conversationDataConverter = conversationDataConverter
        self.participantDataConverter = participantDataConverter
        super.init()
        conversationsEventPropogator.addClientListener(self)
    }

    func clearConversationList() {
        localCacheProvider.conversationDAO.clearConversationList()
    }

    func getConversationWithSid(_ sid: String) -> RepositoryResultHandle<PersistentConversationDataItem> {
        let obervableFetchRequest = localCacheProvider.conversationDAO.getObservableConversations([sid])
        let resultHandle = RepositoryResultHandle<PersistentConversationDataItem>(with: obervableFetchRequest)
        resultHandle.requestStatus.value = .fetching

        retrieveConversation(sid) { conversation, error in
            guard let conversation = conversation else {
                resultHandle.requestStatus.value = .error(DataFetchError.requiredDataCallsFailed)
                return
            }

            self.retreiveParticipantForConversation(conversation)
            conversation.updateStats(conversationDao: self.localCacheProvider.conversationDAO)
            resultHandle.requestStatus.value = .subscribing
            conversation.delegate = self
            resultHandle.requestStatus.value = .completed
        }

        return resultHandle
    }

    func getObservableMessages(for conversationSid: String) -> ObservableFetchRequestResult<PersistentMessageDataItem> {
        return localCacheProvider.messagesDAO.getObservableConversationMessages(by: conversationSid)
    }

    func getMessages(for conversationSid: String, by pageSize: UInt) -> RepositoryResultHandle<PersistentMessageDataItem> {
        let fetchRequest = localCacheProvider.messagesDAO.getObservableConversationMessages(by: conversationSid)
        let resultHandle = RepositoryResultHandle(with: fetchRequest)

        resultHandle.requestStatus.value = .fetching

        retrieveConversation(conversationSid) { (conversation, error) in
            conversation?.getLastMessages(withCount: pageSize) { (result, messages) in
                guard result.error == nil, let messages = messages else {
                    resultHandle.requestStatus.value = .error(DataFetchError.requiredDataCallsFailed)
                    return
                }

                let items = messages.compactMap { self.messageDataConverter.convert(message: $0) }
                items.forEach {
                    $0.direction = $0.author == self.conversationsProvider.conversationsClient?.user?.identity ? MessageDirection.outgoing : MessageDirection.incoming
                    $0.conversationSid = conversationSid
                }
                self.localCacheProvider.messagesDAO.upsertMessages(items)
                resultHandle.requestStatus.value = .completed
            }
        }

        return resultHandle
    }

    func getMessageWithSid(_ sid: String) -> MessageDataItem? {
        let persistedMessage = localCacheProvider.messagesDAO.getMessageWithSid(sid)
        return persistedMessage?.getMessageDataItem()
    }

    func getMessageWithIndex(messageIndex: NSNumber, onConversation conversationSid: String) -> MessageDataItem? {
        let persistedMessage = localCacheProvider.messagesDAO.getMessageWithIndex(messageIndex: messageIndex, onConversation: conversationSid)
        return persistedMessage?.getMessageDataItem()
    }

    func insertMessages(_ messages: [MessageDataItem], for conversationSid: String) {
        let messagesWithConversationSid: [MessageDataItem] = messages.map { message in
            message.conversationSid = conversationSid
            return message
        }
        localCacheProvider.messagesDAO.upsertMessages(messagesWithConversationSid)
    }

    func updateMessages(_ messages: [MessageDataItem]) {
        localCacheProvider.messagesDAO.upsertMessages(messages)
    }

    func deleteMessagesWithSids(_ messageSids: [String]) {
        localCacheProvider.messagesDAO.deleteMessages(by:  messageSids)
    }

    func getMessageWithUuid(_ uuid: String) -> RepositoryResultHandle<PersistentMessageDataItem> {
        let fetchRequest = localCacheProvider.messagesDAO.getObservableMessageWithUuid(uuid)
        let resultHandle = RepositoryResultHandle(with: fetchRequest)
        return resultHandle
    }

    func getConversationSidToNavigateTo() -> String? {
        let tempSid = navigateToConversationWithSid
        navigateToConversationWithSid = nil
        return tempSid
    }

    // MARK: - Participants methods
    func getTypingParticipants(inConversation conversationSid: String) -> RepositoryResultHandle<PersistentParticipantDataItem> {
        let fetchRequest = localCacheProvider.participantDAO.getTypingParticipants(inConversation: conversationSid)
        let resultHandle = RepositoryResultHandle(with: fetchRequest)
        return resultHandle
    }

    // MARK: - Helpers
    func getConversationList() -> RepositoryResultHandle<PersistentConversationDataItem> {
        let cachedData: ObservableFetchRequestResult<PersistentConversationDataItem> = localCacheProvider.conversationDAO.getObservableConversationList()
        let resultHandle = RepositoryResultHandle<PersistentConversationDataItem>(with: cachedData)
        resultHandle.requestStatus.value = .fetching

        DispatchQueue.global().async {
            guard let conversations = self.conversationsProvider.conversationsClient?.myConversations() else {
                resultHandle.requestStatus.value = .error(DataFetchError.requiredDataCallsFailed)
                return
            }

            let conversationDataItems = conversations.compactMap { conversation in
                self.conversationDataConverter.convert(conversation: conversation)
            }
            self.localCacheProvider.conversationDAO.upsert(conversationDataItems)

            DispatchQueue.main.sync {
                resultHandle.requestStatus.value = .subscribing
            }
            DispatchQueue.global().async {
                conversations.forEach {
                    $0.delegate = self
                    _ = self.getMessages(for: $0.sid!, by: 20)
                }
                DispatchQueue.main.sync {
                    resultHandle.requestStatus.value = .completed
                }
            }
        }

        return resultHandle
    }

    private func retrieveConversation(_ conversationSid: String, completion: @escaping (TCHConversation?, Error?) -> Void) {
        conversationsProvider.conversationsClient?.conversation(withSidOrUniqueName: conversationSid) { (result, conversation) in
            guard result.isSuccessful, let conversation = conversation else {
                completion(nil, DataFetchError.requiredDataCallsFailed)
                self.listener?.onErrorOccured(DataFetchError.requiredDataCallsFailed)
                return
            }
            completion(conversation, nil)
        }
    }

    private func retreiveParticipantForConversation(_ conversation: TCHConversation?) {
        guard let conversationSid = conversation?.sid else {
            return
        }
        let conversationParticipantList = conversation?.participants()
        if let toInsertOrUpdate =
            conversationParticipantList?.compactMap({ participant in participantDataConverter.participantDataItem(from: participant, conversationSid: conversationSid) }) {
            localCacheProvider.participantDAO.upsertParticipants(toInsertOrUpdate)
        }
    }
}

// MARK: TCHConversationDelegate methods

extension ConversationsRepository: TCHConversationDelegate {

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated: TCHConversationUpdate) {
        guard
            let conversationSid = conversation.sid,
            var cachedConversation: ConversationDataItem = localCacheProvider.conversationDAO.getConversationDataItem(sid: conversationSid)
        else {
            // Insert conversation into cache, if it wasn't
            if let item = conversationDataConverter.convert(conversation: conversation) {
                localCacheProvider.conversationDAO.upsert([item])
            }
            return
        }

        switch updated {
        case .uniqueName:
            cachedConversation.uniqueName = conversation.uniqueName ?? ""
        case .friendlyName:
            cachedConversation.friendlyName = conversation.friendlyName ?? ""
        case .userNotificationLevel:
            cachedConversation.notificationLevel = conversation.notificationLevel
        case .lastReadMessageIndex:
            conversation.updateStats(conversationDao: self.localCacheProvider.conversationDAO)
        case .attributes:
            cachedConversation.attributes = conversation.attributes()?.toStringBasedDictionary()
        default:
            return
        }

        cachedConversation.dateUpdated = conversation.dateUpdatedAsDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        localCacheProvider.conversationDAO.upsert([cachedConversation])
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, message: TCHMessage, updated: TCHMessageUpdate) {
        if let messageDataItem = messageDataConverter.convert(message: message) {
            messageDataItem.direction = message.author == self.conversationsProvider.conversationsClient?.user?.identity ? MessageDirection.outgoing : MessageDirection.incoming
            messageDataItem.sendStatus = MessageSendStatus.sent
            messageDataItem.conversationSid = conversation.sid
            localCacheProvider.messagesDAO.upsertMessages([messageDataItem])
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        guard let conversationSid = conversation.sid else {
            return
        }

        if let messageDataItem = messageDataConverter.convert(message: message) {
            messageDataItem.direction = message.author == self.conversationsProvider.conversationsClient?.user?.identity ? MessageDirection.outgoing : MessageDirection.incoming
            messageDataItem.sendStatus = MessageSendStatus.sent
            messageDataItem.conversationSid = conversationSid
            localCacheProvider.messagesDAO.upsertMessages([messageDataItem])
        }

        conversation.updateStats(conversationDao: self.localCacheProvider.conversationDAO)
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageDeleted message: TCHMessage) {
        guard let messageSid = message.sid
        else {
            return
        }
        localCacheProvider.messagesDAO.deleteMessages(by: [messageSid])
        conversation.updateStats(conversationDao: self.localCacheProvider.conversationDAO)
    }

    func conversationsClient(_ client: TwilioConversationsClient,
                             conversation: TCHConversation,
                             synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        guard conversation.synchronizationStatus.rawValue >= TCHConversationSynchronizationStatus.all.rawValue else {
            return
        }

        conversation.updateStats(conversationDao: self.localCacheProvider.conversationDAO)
        if conversation.lastReadMessageIndex == nil {
            conversation.setLastReadMessageIndex(0, completion: nil)
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantJoined participant: TCHParticipant) {
        guard let conversationSid = conversation.sid,
              let participantToAdd = participantDataConverter.participantDataItem(from: participant, conversationSid: conversationSid) else {
            fatalError("Participant could not be converted, or conversation sid is nil")
        }
        localCacheProvider.participantDAO.upsertParticipants([participantToAdd])
        conversation.updateStats(conversationDao: self.localCacheProvider.conversationDAO)
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantLeft participant: TCHParticipant) {
        guard let conversationSid = conversation.sid else {
            return
        }

        if participant.identity == client.user?.identity {
            localCacheProvider.conversationDAO.delete([conversationSid])
        }
    }
}

// MARK: - TwilioConversationsClientDelegate methods

extension ConversationsRepository: TwilioConversationsClientDelegate {

    func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
        conversation.delegate = self
        if let item = conversationDataConverter.convert(conversation: conversation) {
            localCacheProvider.conversationDAO.upsert([item])
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        if let conversationSid = conversation.sid {
            localCacheProvider.conversationDAO.delete([conversationSid])
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
        guard let participantSid = participant.sid else {
            return
        }
        localCacheProvider.participantDAO.updateIsTyping(for: participantSid, isTyping: true)
    }

    func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
        guard let participantSid = participant.sid else {
            return
        }
        localCacheProvider.participantDAO.updateIsTyping(for: participantSid, isTyping: false)
    }
}
