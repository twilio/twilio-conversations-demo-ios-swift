//
//  MessageCellDelegate.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol MessageCellDelegate: AnyObject {

    func onMessageLongPressed(_ message: MessageDataListItem)
    func onReactionTapped(forMessage: MessageDataListItem, reactionModel: ReactionViewModel)
    func onImageTapped(message: MessageDataListItem)
    func onRetryToSendMediaMessage(_ forMessage: MessageDataListItem)
    func onRetryToDownloadMediaMessage(_ forMessage: MessageDataListItem)
}
