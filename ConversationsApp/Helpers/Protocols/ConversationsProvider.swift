//
//  ConversationsProvider.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient


enum LoginResult {

    case success
    case failure(Error)
}

protocol ConversationsProvider: TwilioConversationsClientDelegate, TCHConversationDelegate {
    
    // MARK:- Properties
    var conversationsClient: TwilioConversationsClient? { get }
    
    // MARK:- Conversations life cycle base functionality
    func create(login: String, password: String, delegate: TwilioConversationsClientDelegate, completion: @escaping (LoginResult) -> Void)
    func create(login: String, password: String, tokenWrapper: TokenWrapper.Type, delegate: TwilioConversationsClientDelegate, completion: @escaping (LoginResult) -> Void)
    func shutdown()
}
