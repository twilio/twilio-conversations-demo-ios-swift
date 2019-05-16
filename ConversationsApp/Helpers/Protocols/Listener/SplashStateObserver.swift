//
//  SplashStateObserver.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol SplashStateObserver: AnyObject {

    func onStatusChanged()
    func onRetryStateChanged()
    func onSignOutStateChanged()
    func onDisplayError(_ error: Error, onAcknowledged: (() -> Void)?)
    func onShowLoginScreen()
    func onShowConversationListScreen()
}
