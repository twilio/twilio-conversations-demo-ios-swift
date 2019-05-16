//
//  MomentaryConversationCache.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

class MomentaryConversationCache {

    // MARK: Properties

    private(set) var conversationsProvider: ConversationsProvider?
    private var cachedConversations: [String: TCHConversation] = [:]

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper) {
        self.conversationsProvider = conversationsProvider
    }

    // MARK: Methods

    func getConversation(with sidOrUniqueName: String, onError: @escaping (Error?) -> Void, onSuccess: @escaping (TCHConversation) -> Void) {
        if let conversation = self.cachedConversations[sidOrUniqueName] {
            onSuccess(conversation)
            return
        }

        guard let client = conversationsProvider?.conversationsClient else {
            onError(ActionError.unknown)
            return
        }

        client.conversation(withSidOrUniqueName: sidOrUniqueName) { [weak self] result, conversation in
            guard let conversation = conversation else  {
                onError(result.error)
                return
            }

            self?.cachedConversations[sidOrUniqueName] = conversation
            onSuccess(conversation)
        }
    }
}
