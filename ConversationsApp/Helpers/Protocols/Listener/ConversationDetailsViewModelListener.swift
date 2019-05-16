//
//  ConversationDetailsViewModelListener.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol ConversationDetailsViewModelListener: AnyObject {

    func onConversationUpdated()
    func onDisplayError(_ error: Error)
    func onActionsListUpdate()
    func onParticipantAdded(identity: String)
}
