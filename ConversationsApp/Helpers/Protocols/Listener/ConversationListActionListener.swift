//
//  ConversationListActionListener.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ConversationListActionListener: AnyObject {

    func onJoinConversation(sid: String)
    func onJoinConversation(uniqueName: String)
    func onAddParticipant(participantIdentity: String, conversationSid: String)
    func onDestroyConversation(sid: String)
    func onSetConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel)
}
