//
//  ParticipantDataProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ParticipantDataConverterProtocol {

    func participantDataItem(from participant: TCHParticipant, conversationSid: String) -> ParticipantDataItem?
}
