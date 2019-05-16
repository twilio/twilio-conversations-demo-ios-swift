//
//  UserProfileViewModelListener.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol UserProfileViewModelListener: AnyObject {

    func onFriendlyNameUpdated()
    func onDisplayError(_ error: Error)
}
