//
//  LocalConversationsCacheProvider.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient
import CoreData

class LocalConversationsCacheProvider: LocalCacheProvider {

    static let shared = LocalConversationsCacheProvider()

    let participantDAO: ParticipantDAO
    let conversationDAO: ConversationDAO
    let messagesDAO: MessageDAO
    let reactionDAO: ReactionDAO

    init(participantDAO: ParticipantDAO = ParticipantDAOImpl(),
                 conversationDAO: ConversationDAO = ConversationDAOImpl(),
                 messagesDAO: MessageDAO = MessageDAOImpl(),
                 reactionDAO: ReactionDAO = ReactionDAOImpl()
    ) {
        self.participantDAO = participantDAO
        self.conversationDAO = conversationDAO
        self.messagesDAO = messagesDAO
        self.reactionDAO = reactionDAO
    }
}
