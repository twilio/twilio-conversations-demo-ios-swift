//
//  SignInController.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 15.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class SignInController {

    lazy var signInContainerVC = SignInContainerVC(initialView: signInProgressView)

    private lazy var credentialsInput = CredentialsInput()
    private lazy var signInProgressView = SignInProgressView()
    private let loginManager: LoginManager
    private let credentialStorage: CredentialStorage

    init(loginManager: LoginManager = ConversationsLoginManager(),
         credentialStorage: CredentialStorage = ConversationsCredentialStorage.shared) {
        self.loginManager = loginManager
        self.credentialStorage = credentialStorage
        credentialsInput.onButtonTap = onSignIn(username:password:)
        
        print("Sign in controller created")

        loginManager.signInUsingStoredCredentials { result in
            switch result {
            case .success:
                self.goToConversationListScreen()
            case .failure(_):
                self.signInContainerVC.initialView = nil
                DispatchQueue.main.async {
                    self.signInContainerVC.embedViewInContainer(self.credentialsInput)
                }
            }
        }
    }

    private func onSignIn(username: String?, password: String?) {
        guard let username = username, let password = password, !username.isEmpty else {
            credentialsInput.setError(text: NSLocalizedString("Enter a username and password to sign in.", comment: "When one of username or password is empty"))
            return
        }

        DispatchQueue.main.async {
            self.signInContainerVC.embedViewInContainer(self.signInProgressView)
        }

        loginManager.signIn(identity: username, password: password) { result in
            switch result {
            case .success:
                self.goToConversationListScreen()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.signInContainerVC.embedViewInContainer(self.credentialsInput)
                    self.credentialsInput.setError(text: error.localizedDescription)
                }
            }
        }
    }

    private func goToConversationListScreen() {
        let conversationListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window??.rootViewController = conversationListVC
        }
    }
}
