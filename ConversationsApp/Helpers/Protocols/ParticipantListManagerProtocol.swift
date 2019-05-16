//
//  ParticipantListManagerProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ParticipantListManagerProtocol: AnyObject {

    // MARK: Methods
    func getParticipants(conversationSid: String,
                         completion: @escaping (Result<[TCHParticipant], Error>) -> Void)
    func remove(participant: TCHParticipant,
                fromConversationWith sidOrUniqueName: String,
                completion: @escaping (Error?) -> Void)
}
