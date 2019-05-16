//
//  LoginManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol LoginManager {

    func signIn(identity: String, password: String, completion: @escaping (LoginResult) -> Void)
    func signInUsingStoredCredentials(completion: @escaping (LoginResult) -> Void)
}
