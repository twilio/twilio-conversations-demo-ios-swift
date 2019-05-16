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
    private var momentaryConversationCache: MomentaryConversationCache?

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper) {
        self.conversationsProvider = conversationsProvider
        self.momentaryConversationCache = MomentaryConversationCache(conversationsProvider: conversationsProvider)

        if let devicePushToken = ConversationsRepository.shared.devicePushToken,
           let conversationsClient = conversationsProvider.conversationsClient {
            conversationsClient.register(withNotificationToken: devicePushToken) { result in
                print("Device push token registration was\(result.isSuccessful ? "" : " not") successful")
            }
        }
    }

    // MARK: ConversationListManagerProtocol

    func joinConversation(_ sidOrUniqueName: String, completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sidOrUniqueName, onError: completion) { conversation in
            conversation.join { result in
                completion(result.error)
            }
        }
    }

    func leaveConversation(sid: String, completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sid, onError: completion) { conversation in
            conversation.leave { result in
                completion(result.error)
            }
        }
    }

    func setConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel, completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sid, onError: completion) { conversation in
            conversation.setNotificationLevel(level) { result in
                completion(result.error)
            }
        }
    }

    func destroyConversation(sid: String, completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sid, onError: completion) { conversation in
            conversation.destroy { result in
                completion(result.error)
            }
        }
    }

    func setConversationFriendlyName(sid: String, friendlyName: String?,  completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sid, onError: completion) { conversation in
            conversation.setFriendlyName(friendlyName) { result in
                completion(result.error)
            }
        }
    }

    func addParticipant(identity: String, sid: String,  completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sid, onError: completion) { conversation in
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
            completion(ActionError.unknown)
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

    // MARK: Helper methods

    private func getCachedConversation(withSid sid: String,
                                       onError: @escaping (Error?) -> Void,
                                       onSuccess: @escaping (TCHConversation) -> Void) {
        guard let cache = momentaryConversationCache else {
            onError(ActionError.notAbleToRetrieveCachedMessage)
            return
        }

        cache.getConversation(with: sid, onError: onError, onSuccess: onSuccess)
    }
}
