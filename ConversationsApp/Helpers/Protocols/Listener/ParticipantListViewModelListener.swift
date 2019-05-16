//
//  ConversationDetailsViewModelListener.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ParticipantListViewModelListener: AnyObject {

    func onParticipantsUpdated()
    func onDisplayError(_ error: Error)
    func onParticipantTap(_ participant: TCHParticipant)
    func onParticipantRemoved(_ participant: TCHParticipant)
}
