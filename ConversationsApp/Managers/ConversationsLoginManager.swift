//
//  ConversationsLoginManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

class ConversationsLoginManager: LoginManager {

    // MARK: Properties

    private var conversationsProvider: ConversationsProvider
    private var conversationsCredentialStorage: CredentialStorage

    // MARK: Intialization

    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper,
         credentialStorage: CredentialStorage = ConversationsCredentialStorage.shared) {
        self.conversationsProvider = conversationsProvider
        self.conversationsCredentialStorage = credentialStorage
    }

    // MARK: Sign in logic

    func signIn(identity: String, password: String, completion: @escaping (LoginResult) -> Void) {
        conversationsProvider.create(login: identity, password: password) { [weak self] result in
            if case .success = result {
                // Save credentials
                do {
                    try self?.conversationsCredentialStorage.saveCredentials(identity: identity, password: password)
                } catch (let error){
                    print(error.localizedDescription)
                    return completion(.failure(LoginError.unableToStoreCredentials))
                }
            }
            completion(result)
        }
    }

    func signInUsingStoredCredentials(completion: @escaping (LoginResult) -> Void) {
        guard
            let latestCredentials = try? conversationsCredentialStorage.loadLatestCredentials(),
            let pass = try? latestCredentials.readPassword()
        else {
            try? conversationsCredentialStorage.deleteCredentials()
            completion(.failure(LoginError.accessDenied))
            return
        }

        signIn(identity: latestCredentials.account, password: pass) { [weak self] result in
            if case .failure(LoginError.accessDenied) = result {
                try? self?.conversationsCredentialStorage.deleteCredentials()
            }

            completion(result)
        }
    }
}

