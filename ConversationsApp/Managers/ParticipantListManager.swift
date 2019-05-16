//
//  ParticipantListManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ParticipantListManager: ParticipantListManagerProtocol {

    // MARK: Properties

    private(set) weak var conversationsRepository: ConversationsRepositoryProtocol?
    private var momentaryConversationCache: MomentaryConversationCache?

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper,
         ConversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared) {
        self.conversationsRepository = ConversationsRepository
        self.momentaryConversationCache = MomentaryConversationCache(conversationsProvider: conversationsProvider)
    }

    // MARK: Methods

    func getParticipants(conversationSid: String, completion: @escaping (Result<[TCHParticipant], Error>) -> Void) {
        guard let cache = momentaryConversationCache else {
            completion(.failure(ActionError.unknown))
            return
        }

        cache.getConversation(with: conversationSid) { error in
            completion(.failure(ActionError.conversationNotAvailable))
        } onSuccess: { conversation in
            completion(.success(conversation.participants()))
        }
    }

    func remove(participant: TCHParticipant, fromConversationWith sidOrUniqueName: String, completion: @escaping (Error?) -> Void) {
        guard let cache = momentaryConversationCache else {
            completion(ActionError.unknown)
            return
        }

        cache.getConversation(with: sidOrUniqueName, onError: completion) { conversation in
            conversation.removeParticipant(participant) { result in
                completion(result.error)
            }
        }
    }
}
