//
//  TCHAdapter.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/10/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

/// Abstract:
///     TCHAdapter provides methods to transform 'TCH' objects' from TwilioConversationsClient  to 'Business' types, like Conversation, Particpant.
///
/// Usage:
///   Use TCHAdapter to transform from 'TCHParticipant'  model to 'Participant'
///   Use TCHAdapter to transform from 'TCHConversation'  model to 'Conversation'

struct TCHAdapter {
    
    //Transform a 'TCHConversation' to 'Conversation' model
    static func transform(from tchConversation: TCHConversation) -> Conversation {
        guard let sid = tchConversation.sid, !sid.isEmpty else {
            fatalError("TCHConversation sid shouldn't be nil.")
        }
        return Conversation(sid: sid)
    }
    
    //Transform a 'TCHParticipant' to 'Participant' model
    static func transform(from tchParticipant: TCHParticipant) -> Participant {
        guard let sid = tchParticipant.sid, !sid.isEmpty else {
            fatalError("TCHParticipant sid shouldn't be nil.")
        }
        return Participant(sid: sid, identity: tchParticipant.identity)
    }
}
