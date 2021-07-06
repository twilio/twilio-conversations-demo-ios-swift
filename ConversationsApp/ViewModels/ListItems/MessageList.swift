//
//  MessageList.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol MessageItemsDelegate {
    func onItemsChanged(items: [MessageListItemCell])
}

struct MessageList {

    private var messageItems = [MessageDataListItem]()

    private var participantsTyping = [TypingParticipantViewModel]()

    static let messageListOrder: (MessageDataListItem, MessageDataListItem) -> (Bool) = { $0.dateCreated < $1.dateCreated }

    var delegate: MessageItemsDelegate?

    mutating func updateMessages(from items: [PersistentMessageDataItem]) {
        messageItems = items.compactMap { MessageDataListItem(item: $0.getMessageDataItem()) }
            .sorted(by: Self.messageListOrder)
        delegate?.onItemsChanged(items: self.buildItems())
    }

    mutating func updateTypingParticipants(for items: [PersistentParticipantDataItem]) {
        participantsTyping = items.compactMap {TypingParticipantViewModel(participant: $0.getParticipantDataItem()) }
        delegate?.onItemsChanged(items: self.buildItems())
    }

    private func buildItems() -> [MessageListItemCell] {
        var items = [MessageListItemCell]()
        items.append(contentsOf: messageItems)
        items.append(contentsOf: participantsTyping)
        return items
    }
}
