//
//  ParticipantListManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ParticipantListManager: ParticipantListManagerProtocol {

    // MARK: Properties

    private let conversationsProvider: ConversationsProvider

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper) {
        self.conversationsProvider = conversationsProvider
    }

    // MARK: Methods

    func getParticipants(conversationSid: String, completion: @escaping (Result<[TCHParticipant], Error>) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(.failure(DataFetchError.conversationsClientIsNotAvailable))
            return
        }

        client.conversation(withSidOrUniqueName: conversationSid) { result, conversation in
            guard let conversation = conversation else {
                completion(.failure(DataFetchError.requiredDataCallsFailed))
                return
            }

            completion(.success(conversation.participants()))
        }
    }

    func remove(participant: TCHParticipant, fromConversationWith sidOrUniqueName: String, completion: @escaping (Error?) -> Void) {
        guard let client = conversationsProvider.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: sidOrUniqueName) { result, conversation in
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.removeParticipant(participant) { result in
                completion(result.error)
            }
        }
    }
}
