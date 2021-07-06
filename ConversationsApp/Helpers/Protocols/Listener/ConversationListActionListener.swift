//
//  ConversationListActionListener.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ConversationListActionListener: AnyObject {

    func onJoinConversation(with id: String)
    func onAddParticipant(participantIdentity: String, conversationSid: String)
    func onLeaveConversation(sid: String)
    func onSetConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel)
}
