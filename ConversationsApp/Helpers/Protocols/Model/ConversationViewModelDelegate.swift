//
//  ConversationViewModelListener.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol ConversationViewModelDelegate: AnyObject {

    func onConversationUpdated()
    func messageListUpdated(from: [MessageListItemCell], to: [MessageListItemCell])
    func onDisplayReactionList(forReaction: String, onMessage: String)
    func onMessageLongPressed(_ message: MessageDataListItem)
    func onDisplayError(_ error: Error)
    func showFullScreenImage(mediaSid: String, imageUrl: URL)
}
