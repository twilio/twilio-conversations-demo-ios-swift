//
//  CredentialStorage.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

class ConversationsCredentialStorage: CredentialStorageProtocol {

    // MARK: Properties

    static let shared = ConversationsCredentialStorage()
    private var serviceName = "ConversationsAppCredentials"
    private var accessGroup: String? = nil
    
    // MARK: Intialization

    private init() {}

    // MARK: CredentialStorage
    
    func saveCredentials(identity: String, password: String) throws {
        let passwordItem = KeychainPasswordItem(service: serviceName, account: identity, accessGroup: accessGroup)
        try passwordItem.savePassword(password)
    }
    
    func loadCredentials(identity: String) throws -> String {
        let passwordItem = KeychainPasswordItem(service: serviceName, account: identity, accessGroup: accessGroup)
        return try passwordItem.readPassword()
    }

    func loadLatestCredentials() throws -> KeychainPasswordItem? {
        return try KeychainPasswordItem.passwordItems(forService: serviceName, accessGroup: accessGroup).last
    }

    func deleteCredentials() throws {
        try KeychainPasswordItem.deleteCredentials(forService: serviceName)
    }

    func changeService(name: String) {
        serviceName = name
    }
}
