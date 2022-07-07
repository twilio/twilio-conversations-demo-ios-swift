//
//  Participant.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/10/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation

/// Abstract:
///     A model that represents a Participant - including its sid, identity and all the information that is needed on your app's user interface.
///
/// Usage:
/// This type does not persist any information, it belongs to the business layer, and is intended to be used as a business model.
///     For its equivalent on the Persistance Layer see 'PersistentParticipantDataItem'
///     For its equivalent on the TwilioClient see 'TCHParticipant'
///
/// Use TCHAdapter to transform from 'TCHParticipant'  model to 'Participant'
///
///
struct Participant: Hashable {
    // sid = Participant identifier
    var sid: String
    var identity: String?
    //Add more properties as needed.

}
