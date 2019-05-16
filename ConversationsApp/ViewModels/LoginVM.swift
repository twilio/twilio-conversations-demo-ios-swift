//
//  LoginVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    // MARK: Properties
    
    private let loginManager: LoginManager
    weak var loginStateObserver: LoginStateObserver?
    private(set) var isLoading: Bool = false {
        didSet {
            if oldValue != isLoading {
                loginStateObserver?.onLoadingStateChanged()
            }
        }
    }
    
    // MARK: Intialization
    
    init(loginManager: LoginManager = ConversationsLoginManager()) {
        self.loginManager = loginManager
    }
    
    // MARK: Sign in logic
    
    func signIn(identity: String, password: String) {
        if let validationError = validateSignInDetails(identity: identity, password: password) {
            loginStateObserver?.onSignInFailed(error: validationError)
            return
        }
        
        // Switch state to loading
        isLoading = true
        
        // Perform sign in logic
        loginManager.signIn(identity: identity, password: password) { [weak self] (result) in
            // Switch UI state to stop loading
            self?.isLoading = false
            
            switch result {
            case .failure(let error):
                self?.loginStateObserver?.onSignInFailed(error: error)
            case .success:
                self?.loginStateObserver?.onSignInSucceeded()
            }
        }
    }
    
    private func validateSignInDetails(identity: String, password: String) -> Error? {
        if identity.isEmpty || password.isEmpty {
            return LoginError.allFieldsMustBeFilled
        }
        
        return nil
    }
}
