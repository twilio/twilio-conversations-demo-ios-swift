//
//  ConversationsClientWrapper.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

class ConversationsClientWrapper: NSObject, ObservableObject {

    private(set) var conversationsClient: TwilioConversationsClient?
    var credentialStorage: CredentialStorageProtocol
    var tokenWrapper: TokenWrapper.Type = TokenWrapperImpl.self
    
    init(credentialStorage: CredentialStorageProtocol = ConversationsCredentialStorage.shared) {
        self.credentialStorage = credentialStorage
        super.init()
    }
    
    // MARK: - ConversationsProvider
    func create(login: String, password: String, delegate: TwilioConversationsClientDelegate, completion: @escaping (LoginResult) -> Void) {
        create(login: login, password: password, tokenWrapper: TokenWrapperImpl.self, delegate: delegate, completion: completion)
    }

    func create(login: String, password: String, tokenWrapper: TokenWrapper.Type, delegate: TwilioConversationsClientDelegate, completion: @escaping (LoginResult) -> Void) {
        self.tokenWrapper = tokenWrapper
        tokenWrapper.getConversationsAccessToken(identity: login, password: password) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let conversationsToken):
                // Create conversations client with token
                TwilioConversationsClient.setLogLevel(.silent)

                let properties = TwilioConversationsClientProperties()
                properties.dispatchQueue = DispatchQueue(label: "TwilioConversationsDispatchQueue")
                TwilioConversationsClient.conversationsClient(withToken: conversationsToken,
                                                              properties: properties,
                                                              delegate: delegate) { [weak self] result, client in
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
              let password = try? credentialStorage.loadCredentials(identity: login) else {
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
    
    func registerForPushNotifications(_ deviceToken: Data) {
        if let conversationsClient = conversationsClient, conversationsClient.user != nil {
            conversationsClient.register(withNotificationToken: deviceToken) { (result) in
                if !result.isSuccessful {
                    // try registration again or verify token?
                    // https://www.twilio.com/docs/conversations/ios/push-notifications-ios?code-sample=code-store-registration&code-language=Swift&code-sdk-version=default
                }
            }
        }
    }
    
    func deregisterFromPushNotifications(_ deviceToken: Data) {
        if let conversationsClient = conversationsClient, conversationsClient.user != nil {
            conversationsClient.deregister(withNotificationToken: deviceToken) { (result) in
            }
        }
    }

    // MARK: - Credentials Events
    func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        self.updateToken(shouldLogout: false)
    }

    func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        self.updateToken(shouldLogout: true)
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
                    NSLog("[retry] \(result.debugDescription)")
                    if result.isSuccessful {
                        callback(.success(()))
                    } else {
                        callback(.failure(LoginError.unableToUpdateTokenError))
                    }
                })
            })
    }
}
