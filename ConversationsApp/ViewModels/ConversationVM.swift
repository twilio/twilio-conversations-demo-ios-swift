//
//  ConversationVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

enum MessageAction {
    case react, edit, remove
}

class ConversationViewModel: NSObject {
    
    // MARK: Properties
    private let PAGE_SIZE: UInt = 20

    private let conversationSid: String
    private let conversationsRepository: ConversationsRepositoryProtocol
    private let messagesManager: MessagesManagerProtocol

    private(set) var observableConversation: ObservableFetchRequestResult<PersistentConversationDataItem>?
    lazy private(set) var observableMessageList = conversationsRepository.getObservableMessages(for: conversationSid)
    private(set) var observableTypingParticipantList: ObservableFetchRequestResult<PersistentParticipantDataItem>?
    private(set) var messageItems: [MessageListItemCell] = [] {
        didSet {
            self.delegate?.messageListUpdated(from: oldValue, to: messageItems)
        }
    }

    // Message Items List container
    private var messageList = MessageList()
    var itemCount: Int {
        get {
            self.messageItems.count
        }
    }

    weak var delegate: ConversationViewModelDelegate?

    // MARK: Initialize the Conversation
    init(conversationSid: String, conversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared, messagesManager: MessagesManagerProtocol = MessagesManager()) {
        self.conversationSid = conversationSid
        self.conversationsRepository = conversationsRepository
        self.messagesManager = messagesManager
        super.init()

        messagesManager.conversationSid = conversationSid
        self.messagesManager.delegate = self
        self.messageList.delegate = self
    }

    func sendMessage(message: String) {
        messagesManager.sendTextMessage(to: conversationSid, with: message) { [weak self] (error) in
            if let error = error {
                self?.delegate?.onDisplayError(error)
            }
        }
    }

    func notifyTypingOnConversation(_ conversationSid: String) {
        messagesManager.notifyTypingOnConversation(conversationSid)
    }

    func reactToMessage(withReaction reaction: ReactionType, forMessageSid sid: String) {
        messagesManager.reactToMessage(withSid: sid, withReaction: reaction)
    }

    // Deinitialization
    deinit {
        // During transition, remove observers
        unsubscribeFromConversationChanges()
    }
    
    // Methods
    private func unsubscribeFromConversationChanges() {
        observableConversation?.removeObserver(self)
        observableMessageList.removeObserver(self)
        observervableTypingMemberList?.removeObserver(self)
    }
    
    private func listenForConversationChanges() {
        observableConversation?.observe(with: self) { [weak self] conversationItem in
            self?.delegate?.onConversationUpdated()
        }
    }

    private func listenForTypingParticipant() {
        observervableTypingMemberList?.observe(with: self) {[weak self] participants in
            guard let participants = participants else {
                return
            }
            self?.messageList.updateTypingParticipants(for: participants)
        }
    }

    private func listenForConversationMessagesChanges() {
        observableMessageList.observe(with: self) { [weak self] messages in
            guard let messages = messages else {
                return
            }
            self?.messageList.updateMessages(from: messages)
        }
    }
    
    func loadConversation() {
        observableConversation = fetchConversation(sid: conversationSid)
        observervableTypingMemberList = conversationsRepository.getTypingParticipants(inConversation: conversationSid).data
        listenForConversationChanges()
        listenForConversationMessagesChanges()
        listenForTypingParticipant()
    }
    
    private func fetchConversation(sid: String) -> ObservableFetchRequestResult<PersistentConversationDataItem> {
        let resultHandle = conversationsRepository.getConversationWithSid(sid)
        
        resultHandle.requestStatus.observe(with: self) { status in
            switch status {
            case .error(let error):
                self.delegate?.onDisplayError(error)
            default:
                break
            }
        }
        
        return resultHandle.data
    }
    
    private func fetchMessages() -> ObservableFetchRequestResult<PersistentMessageDataItem> {
        return conversationsRepository.getObservableMessages(for: conversationSid)
    }

    private func createConversationMessageListViewModels(from items: [MessageDataItem]) -> [MessageDataListItem] {
        return items.compactMap { MessageDataListItem(item: $0) }
    }

    func sendMediaMessage(inputStream: InputStream, mimeType: String, inputSize: Int ) {
        messagesManager.sendMediaMessage(toConversationWithSid: conversationSid, inputStream: inputStream, mimeType: mimeType, inputSize: inputSize)
    }

    func getActionOnMessage(_ message: MessageDataListItem) -> [MessageAction] {
        guard let messageSid = message.sid else {
            return []
        }

        var actions: [MessageAction] = [.react]
        if messagesManager.isCurrentUserAuthorOf(messageWithSid: messageSid) {
            actions.append(.edit)
            actions.append(.remove)
        }
        return actions
    }

    func deleteMessage(_ message: MessageDataListItem) {
        NSLog("[ConversationViewModel] deleteMessage -> \(message.index) sid: \(String(describing: message.sid))")
        guard let messageSid = message.sid else {
            delegate?.onDisplayError(DataFetchError.dataIsInconsistent)
            return
        }
        messagesManager.removeMessage(withIndex: message.index, messageSid: messageSid)
    }

}

extension ConversationViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel: MessageListItemCell = messageItems[indexPath.row]
        switch (cellViewModel.itemType) {
        case .incomingMessage:
            let cell: IncomingMessageCell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.itemType.rawValue) as! IncomingMessageCell
            cell.setup(with: cellViewModel as! MessageDataListItem, withDelegate:  self)
            return cell
        case .outgoingMessage:
            let cell: OutgoingMessageCell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.itemType.rawValue) as! OutgoingMessageCell
            cell.setup(with: cellViewModel as! MessageDataListItem, withDelegate: self)
            return cell
        case .typingMember:
            let cell: ParticipantTypingCell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.itemType.rawValue) as! ParticipantTypingCell
            return cell
        case .outgoingMediaMessage:
            let cell: OutgoingMediaMessageCell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.itemType.rawValue) as! OutgoingMediaMessageCell
            let vm =  cellViewModel as! MessageDataListItem
            cell.setup(with: cellViewModel as! MessageDataListItem, withDelegate: self)
            messagesManager.startMediaMessageDownloadForIndex(vm.index)
            return cell
        case .incomingMediaMessage:
            let cell: IncomingMediaMessageCell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.itemType.rawValue) as! IncomingMediaMessageCell
            let vm =  cellViewModel as! MessageDataListItem
            cell.setup(with: cellViewModel as! MessageDataListItem, withDelegate: self)
            messagesManager.startMediaMessageDownloadForIndex(vm.index)
            return cell
        }
    }
}

extension ConversationViewModel: OutgoingMessageDelegate {
    func onRetryPressedForMessageItem(_ item: MessageDataListItem) {
        messagesManager.retrySendMessageWithUuid(item.messageUuid) { [weak self] error in
            if let error = error {
                self?.delegate?.onDisplayError(error)
            }
        }
    }
}


extension ConversationViewModel: MessageItemsDelegate {
    func onItemsChanged(items: [MessageListItemCell]) {
        self.messageItems = items
        self.delegate?.onConversationUpdated()
    }
}

extension ConversationViewModel: MessageManagerDelegate {
    func onMessageManagerError(_ error: Error) {
        self.delegate?.onDisplayError(error)
    }
}

extension ConversationViewModel: MessageCellDelegate {
    func onMessageLongPressed(_ message: MessageDataListItem) {
        delegate?.onMessageLongPressed(message)
    }

    func onImageTapped(message: MessageDataListItem) {
        guard let imageUrl = message.mediaProperties?.url,
              let mediaSid = message.mediaSid else {
            return
        }
        delegate?.showFullScreenImage(mediaSid: mediaSid, imageUrl: imageUrl)
    }

    func onReactionTapped(forMessage message: MessageDataListItem, reactionModel: ReactionViewModel) {
        guard let messageSid = message.sid else {
            return
        }
        self.delegate?.onDisplayReactionList(forReaction: reactionModel.reactionSymbol, onMessage: messageSid)
    }

    func onRetryToSendMediaMessage(_ message: MessageDataListItem) {
        messagesManager.retrySendMediaMessageWithUuid(message.messageUuid)
    }

    func onRetryToDownloadMediaMessage(_ forMessage: MessageDataListItem) {
        messagesManager.startMediaMessageDownloadForIndex(forMessage.index)
    }
}
