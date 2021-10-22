//
//  ConversationDetailsManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ConversationDetailsManager: ConversationDetailsManagerProtocol {

    // MARK: Properties

    private var conversationsProvider: ConversationsProvider

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper) {
        self.conversationsProvider = conversationsProvider
    }

    // MARK: ConversationDetailsManagerProtocol

    func addParticipant(identity: String, sid: String, completion: @escaping (Error?) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: sid) { result, conversation in
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.addParticipant(byIdentity: identity, attributes: nil) { result in
                completion(result.error)
            }
        }
    }

    func setConversationFriendlyName(sid: String, friendlyName: String?, completion: @escaping (Error?) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: sid) { result, conversation in
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.setFriendlyName(friendlyName) { result in
                completion(result.error)
            }
        }
    }

    func setConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel, completion: @escaping (Error?) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: sid) { result, conversation in
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.setNotificationLevel(level) { result in
                completion(result.error)
            }
        }
    }

    func destroyConversation(sid: String, completion: @escaping (Error?) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: sid) { result, conversation in
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.destroy { result in
                completion(result.error)
            }
        }
    }
}
