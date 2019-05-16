//
//  SplashVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

class SplashViewModel {

    // MARK: Properties

    private let loginManager: LoginManager
    private var conversationsCredentialStorage: CredentialStorage
    weak var splashStateObserver: SplashStateObserver?

    private(set) var status = SplashScreenStatus.idle {
        didSet {
            if oldValue != status {
                splashStateObserver?.onStatusChanged()
            }
        }
    }

    private(set) var retryVisible = false {
        didSet {
            if oldValue != retryVisible {
                splashStateObserver?.onRetryStateChanged()
            }
        }
    }

    private(set) var signOutVisible = false {
        didSet {
            if oldValue != signOutVisible {
                splashStateObserver?.onSignOutStateChanged()
            }
        }
    }

    // MARK: Intialization

    init(loginManager: LoginManager = ConversationsLoginManager(), credentialStorage: CredentialStorage = ConversationsCredentialStorage.shared) {
        self.loginManager = loginManager
        self.conversationsCredentialStorage = credentialStorage
    }

    // MARK: Sign in/out logic

    func signIn() {
        status = .connecting
        loginManager.signInUsingStoredCredentials { (result) in
            switch result {
            case .success:
                self.splashStateObserver?.onShowConversationListScreen()
            case .failure(let error):
                self.handleError(error)
            }
            self.status = .idle
        }
    }

    func signOut() {
        try? conversationsCredentialStorage.deleteCredentials()
        splashStateObserver?.onShowLoginScreen()
    }

    private func handleError(_ error: Error) {
        self.splashStateObserver?.onDisplayError(error) {
            if let loginError = error as? LoginError, loginError == .accessDenied {
                self.signOut()
            } else {
                self.signOutVisible = true
                self.retryVisible = true
            }
        }
    }
}
