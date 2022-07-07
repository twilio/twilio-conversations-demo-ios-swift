//
//  CredentialStorage.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol CredentialStorageProtocol {

    // MARK: Keychain Actions

    func saveCredentials(identity: String, password: String) throws
    func loadCredentials(identity: String) throws -> String
    func loadLatestCredentials() throws -> KeychainPasswordItem?
    func deleteCredentials() throws
    func changeService(name: String)
}
