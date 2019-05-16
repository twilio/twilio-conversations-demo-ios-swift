//
//  ConversationListObserver.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol ConversationListObserver: AnyObject {

    func onDataChanged()
    func onDisplayError(_ error: Error)
    func onLogout()
    func onNotificationTap()
}
