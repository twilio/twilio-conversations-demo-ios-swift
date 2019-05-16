//
//  ConversationDetailsManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ConversationDetailsManager: ConversationDetailsManagerProtocol {

    // MARK: Properties

    private var momentaryConversationCache: MomentaryConversationCache?

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper) {
        self.momentaryConversationCache = MomentaryConversationCache(conversationsProvider: conversationsProvider)
    }

    // MARK: ConversationDetailsManagerProtocol

    func addParticipant(identity: String, sid: String, completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sid, onError: completion) { conversation in
            conversation.addParticipant(byIdentity: identity, attributes: nil) { result in
                completion(result.error)
            }
        }
    }

    func setConversationFriendlyName(sid: String, friendlyName: String?, completion: @escaping (Error?) -> Void) {
        getCachedConversation(withSid: sid, onError: completion) { conversation in
            conversation.setFriendlyName(friendlyName) { result in
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
