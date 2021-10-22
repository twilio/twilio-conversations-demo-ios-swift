//
//  MessageListViewItemType.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol MessageListItemCell {

    var itemType: MessagesTableCellViewType { get }
}

enum MessagesTableCellViewType: String {

    case typingMember = "ParticipantTypingCell"
    case incomingMessage = "IncomingMessageCell"
    case outgoingMessage = "OutgoingMessageCell"
    case outgoingMediaMessage = "OutgoingMediaMessageCell"
    case incomingMediaMessage = "IncomingMediaMessageCell"
}

struct TypingParticipantViewModel: MessageListItemCell {

    let itemType: MessagesTableCellViewType = .typingMember
    let participant: ParticipantDataItem
}

