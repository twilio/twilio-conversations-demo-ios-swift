//
//  ConversationListManagerProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ConversationListManagerProtocol {

    // MARK: Properties

    var conversationsProvider: ConversationsProvider { get }

    // MARK: Methods for managing conversations

    func createAndJoinConversation(friendlyName: String?, completion: @escaping (Error?) -> Void)
    func joinConversation(_ sidOrUniqueName: String, completion: @escaping (Error?) -> Void)
    func leaveConversation(sid: String, completion: @escaping (Error?) -> Void)
    func setConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel, completion: @escaping (Error?) -> Void)
    func destroyConversation(sid: String, completion: @escaping (Error?) -> Void)
    func setConversationFriendlyName(sid: String, friendlyName: String?,  completion: @escaping (Error?) -> Void)
    func addParticipant(identity: String, sid: String,  completion: @escaping (Error?) -> Void)
}
