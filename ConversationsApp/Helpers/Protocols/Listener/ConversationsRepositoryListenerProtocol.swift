//
//  RepositoryListenerProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol ConversationsRepositoryListenerProtocol: AnyObject {

    func onErrorOccured(_ error: Error)
    func pushNotificationTapped()
}
