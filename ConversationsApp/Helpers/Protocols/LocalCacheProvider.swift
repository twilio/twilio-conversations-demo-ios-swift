//
//  LocalCacheProvider.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

protocol LocalCacheProvider {

    // MARK: - DAOAccessors
    var participantDAO: ParticipantDAO { get }
    var conversationDAO: ConversationDAO { get }
    var messagesDAO: MessageDAO { get }
    var reactionDAO: ReactionDAO { get }
}
