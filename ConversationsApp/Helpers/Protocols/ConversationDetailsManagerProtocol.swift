//
//  ConversationDetailsManagerProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ConversationDetailsManagerProtocol {

    // MARK: Methods

    func addParticipant(identity: String, sid: String, completion: @escaping (Error?) -> Void)
    func setConversationFriendlyName(sid: String, friendlyName: String?, completion: @escaping (Error?) -> Void)
    func setConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel, completion: @escaping (Error?) -> Void)
    func destroyConversation(sid: String, completion: @escaping (Error?) -> Void)
}
