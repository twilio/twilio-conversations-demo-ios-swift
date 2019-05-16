//
//  LoginStateObserver.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol LoginStateObserver: AnyObject {

    func onLoadingStateChanged()
    func onSignInSucceeded()
    func onSignInFailed(error: Error)
}
