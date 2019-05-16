//
//  ConversationsEventPropagator.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ConversationsEventPropagator {
    
    // MARK: Properties
    
    var conversationsClientObservers: [WeakWrapper<TwilioConversationsClientDelegate>] { get }
    
    // MARK: Add or remove listeners
    
    func addClientListener(_ listener: TwilioConversationsClientDelegate)
    func removeClientListener(_ listener: TwilioConversationsClientDelegate)
    
    // MARK: Propagation
    
    func propagateClientEvent(_ listenerClosure: (TwilioConversationsClientDelegate) -> Void)
}
