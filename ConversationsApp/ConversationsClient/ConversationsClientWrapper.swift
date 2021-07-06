//
//  ConversationsClientWrapper.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

class ConversationsClientWrapper: NSObject, ConversationsProvider, ConversationsEventPropagator {

    static let wrapper = ConversationsClientWrapper()
    private(set) var conversationsClient: TwilioConversationsClient?
    var conversationsCredentialStorage: CredentialStorage
    private(set) var conversationsClientObservers: [WeakWrapper<TwilioConversationsClientDelegate>] = []

    var tokenWrapper: TokenWrapper.Type = TokenWrapperImpl.self
    
    init(ConversationsCredentialStorage: CredentialStorage = ConversationsCredentialStorage.shared) {
        self.conversationsCredentialStorage = ConversationsCredentialStorage
        super.init()
    }
    
    // MARK: - ConversationsProvider
    func create(login: String, password: String, completion: @escaping (LoginResult) -> Void) {
        create(login: login, password: password, tokenWrapper: TokenWrapperImpl.self, completion: completion)
    }

    func create(login: String, password: String, tokenWrapper: TokenWrapper.Type, completion: @escaping (LoginResult) -> Void) {
        self.tokenWrapper = tokenWrapper
        tokenWrapper.getConversationsAccessToken(identity: login, password: password) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let conversationsToken):
                // Create conversations client with token
                TwilioConversationsClient.setLogLevel(.warning)

                let properties = TwilioConversationsClientProperties()
                properties.dispatchQueue = DispatchQueue(label: "TwilioConversationsDispatchQueue")
                TwilioConversationsClient.conversationsClient(withToken: conversationsToken,
                                                              properties: properties,
                                                              delegate: self) { [weak self] result, client in
                    DispatchQueue.main.async {
                        if result.isSuccessful, let client = client  {
                            self?.conversationsClient = client
                            completion(.success)
                        } else {
                            completion(.failure(result.error!))
                        }
                    }
                }
            }
        }
    }

    func updateToken(shouldLogout: Bool) {
        guard let login = conversationsClient?.user?.identity,
              let password = try? conversationsCredentialStorage.loadCredentials(identity: login) else {
            handleUpdateTokenFailure(shouldLogout: shouldLogout)
            return
        }
        let getAccessTokenOp = tokenWrapper.buildGetAccessTokenOperation(username: login, password: password)
        retry(operation: getAccessTokenOp) { result in
            switch result {
            case .success(let token):
                retry(operation: self.buildUpdateTokenOperation(with: token)) { updateTokenResult in
                    switch updateTokenResult {
                    case .success():
                        NSLog("Token updated")
                    case .failure(let error):
                        NSLog("Get token error during token update: \(error)")
                        self.handleUpdateTokenFailure(shouldLogout: shouldLogout)
                    }
                }
            case.failure(let error):
                self.handleUpdateTokenFailure(shouldLogout: shouldLogout)
                NSLog("Get token error while getAccessToken during token update: \(error)")
            }
        }
    }

    func shutdown() {
        conversationsClient?.shutdown()
        conversationsClient = nil
    }

    // MARK: - ConversationsEventPropagator

    func addClientListener(_ listener: TwilioConversationsClientDelegate) {
        if !conversationsClientObservers.contains(where: { $0 === listener }) {
            conversationsClientObservers.append(WeakWrapper(wrappedValue: listener))
        }
    }

    func removeClientListener(_ listener: TwilioConversationsClientDelegate) {
        conversationsClientObservers.removeAll { $0 === listener }
    }

    func propagateClientEvent(_ listenerClosure: (TwilioConversationsClientDelegate) -> Void) {
        conversationsClientObservers.forEach { listener in
            if let listener = listener.wrappedValue {
                listenerClosure(listener)
            }
        }
        conversationsClientObservers.removeAll { $0.wrappedValue == nil }
    }

    // MARK: - Credentials Events

    func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        self.updateToken(shouldLogout: false)
    }

    func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        self.updateToken(shouldLogout: true)
    }

    // MARK: - Conversation Events

    func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
        propagateClientEvent { (listener) in
            listener.conversationsClient?(client, conversationAdded: conversation)
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        propagateClientEvent { (listener) in
            listener.conversationsClient?(client, conversationDeleted: conversation)
        }
    }

    // MARK: - Helpers

    private func handleUpdateTokenFailure(shouldLogout: Bool) {
        if !shouldLogout {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logoutRequired"), object: nil)
    }

    private func buildUpdateTokenOperation(with token: String) -> AsyncOperation<String, Void> {
        return AsyncOperation(
            input: token,
            task: { input, callback in
                guard let conversationsClient = self.conversationsClient else {
                    callback(.failure(LoginError.unableToUpdateTokenError))
                    return
                }
                conversationsClient.updateToken(input, completion: { result in
                    print("[retry] \(result.debugDescription)")
                    if result.isSuccessful {
                        callback(.success(()))
                    } else {
                        callback(.failure(LoginError.unableToUpdateTokenError))
                    }
                })
            })
    }
}

