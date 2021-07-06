//
//  ParticipantDataItem+Converters.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ParticipantDataConverter: ParticipantDataConverterProtocol {

    func participantDataItem(from participant: TCHParticipant, conversationSid: String) -> ParticipantDataItem? {
        guard let participantSid = participant.sid else {
            return nil
        }

        return ParticipantDataItem(
            sid: participantSid,
            conversationSid: conversationSid,
            identity: participant.identity ?? "sms participant",
            type: Int16(participant.type.rawValue),
            attributes: participant.attributes()?.string,
            isTyping: false
        )
    }
}
