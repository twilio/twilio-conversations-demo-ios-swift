//
//  ConversationListManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ConversationListManager: ConversationListManagerProtocol {

    // MARK: Properties

    private(set) var conversationsProvider: ConversationsProvider

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper) {
        self.conversationsProvider = conversationsProvider

        if let devicePushToken = ConversationsRepository.shared.devicePushToken,
           let conversationsClient = conversationsProvider.conversationsClient {
            conversationsClient.register(withNotificationToken: devicePushToken) { result in
                print("Device push token registration was\(result.isSuccessful ? "" : " not") successful")
            }
        }
    }

    // MARK: ConversationListManagerProtocol

    func joinConversation(_ sidOrUniqueName: String, completion: @escaping (Error?) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: sidOrUniqueName) { result, conversation in
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.join { result in
                completion(result.error)
            }
        }
    }

    func leaveConversation(sid: String, completion: @escaping (Error?) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: sid) { result, conversation in
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.leave { result in
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

    func createAndJoinConversation(friendlyName: String?, completion: @escaping (Error?) -> Void) {
        let creationOptions: [String: Any] = [
            TCHConversationOptionFriendlyName: friendlyName ?? "",
        ]

        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.createConversation(options: creationOptions) { result, conversation in
            guard let conversation = conversation else {
                completion(result.error)
                return
            }

            conversation.join { result in
                completion(result.error)
            }
        }
    }
}
