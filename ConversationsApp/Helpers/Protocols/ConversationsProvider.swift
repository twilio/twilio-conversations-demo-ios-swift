//
//  ConversationsProvider.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ConversationsProvider: TwilioConversationsClientDelegate, TCHConversationDelegate {
    
    // MARK:- Properties
    var conversationsClient: TwilioConversationsClient? { get }
    
    // MARK:- Conversations life cycle base functionality
    func create(login: String, password: String, completion: @escaping (LoginResult) -> Void)
    func create(login: String, password: String, tokenWrapper: TokenWrapper.Type, completion: @escaping (LoginResult) -> Void)
    func shutdown()

    // MARK:- Message data retrieval
    func getMessage(parameters: MessageRetrievalRequestParameters, completion: @escaping (Result<TCHMessage, Error>) -> Void)
}
