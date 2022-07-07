//
//  SignInView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 21.10.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

enum ValidationError {
    case none
    case missingUsername
    case missingPassword
    case missingCredentials
    case invalidCredentials
}

struct SignInView: View {

    // MARK: State
    @State private var login: String = ""
    @State private var password: String = ""
    @State private var inProgress: Bool = false
    @State private var errorMessage: String = ""
    @State private var validationError: ValidationError = .none
    
    // MARK: Environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appModel: AppModel

    // MARK: View
    var body: some View {
        VStack(alignment: .center) {
            // in iOS15, the top most view modifies the top area above the safe area's background colour
            // this divider prevents that so that out status message stays within the safe area view
            VStack {
                Divider()
                    .opacity(0.0)
                
                getStatusBanner(status: appModel.globalStatus, errorMessage: errorMessage)
            }
            .frame(height: 42)
            
            BrandHeader()
                .padding(.bottom, 72)
            
            if inProgress {
                SigningInCard()
            } else {
                VStack(alignment: .leading) {
                    UsernameField(login: $login, hasValidationError: isUsernameInvalid(validationError))
                    
                    PasswordField(password: $password, hasValidationError: isPasswordInvalid(validationError))
                    
                    if validationError != .none {
                        Text(getValidationErrorText(validationError))
                            .foregroundColor(Color("ErrorTextColor"))
                            .font(Font.system(size: 14))
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                    }
                    
                    Button(action: {
                        errorMessage = ""
                        signIn()
                    }) {
                        Spacer()
                        Text("signin.button")
                            .font(Font.system(size: 14.0, weight: .bold))
                            .padding(.top, 12)
                            .padding(.bottom, 12)
                        Spacer()
                    }
                    .disabled(inProgress)
                    .foregroundColor(Color.white)
                    .background(RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primaryBackgroundColor))
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                }
                .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color.incomingMessageBackgroundColor))
                .padding()
            }
            
            BrandFooter()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("SignInBackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear(perform: {
            guard
                let latestCredentials = try? appModel.client.credentialStorage.loadLatestCredentials(),
                let pass = try? latestCredentials.readPassword()
            else {
                NSLog("Saved credentials failed, erasing")
                try? appModel.client.credentialStorage.deleteCredentials()

                inProgress = false
                return
            }

            login = latestCredentials.account
            password = pass
            NSLog("Obtained login \(login) and password \(password) from the cred. storage")
            signIn()
        })
    }

    func signIn() {
        NSLog("Manual Sign in")
        
        if login.isEmpty && password.isEmpty {
            validationError = .missingCredentials
            return
        } else if login.isEmpty {
            validationError = .missingUsername
            return
        } else if password.isEmpty {
            validationError = .missingPassword
            return
        }
        
        inProgress = true

        appModel.client.create(login: login, password: password, delegate: appModel) { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.inProgress = false
                    
                    appModel.registerForPushNotifications()
                    
                    // Save credentials
                    do {
                        try appModel.client.credentialStorage.saveCredentials(identity: login, password: password)
                        NSLog("Saving login \(login) and password \(password) from the cred. storage")
                    } catch (let error){
                        errorMessage = error.localizedDescription
                        NSLog("Saving login failed with \(errorMessage)")
                    }

                    // remember current user and identity here
                    appModel.saveUser(appModel.client.conversationsClient?.user)

                    self.appState.current = .main

                case .failure(let error):
                    self.inProgress = false
                    if case .failure(LoginError.accessDenied) = result {
                        NSLog("Sign in failed, erasing credentials")
                        try? appModel.client.credentialStorage.deleteCredentials()
                        
                        self.validationError = .invalidCredentials
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

func isUsernameInvalid(_ error: ValidationError) -> Bool {
    return [.missingUsername, .missingCredentials, .invalidCredentials].contains(where: { $0 == error })
}

func isPasswordInvalid(_ error: ValidationError) -> Bool {
    return [.missingPassword, .missingCredentials, .invalidCredentials].contains(where: { $0 == error })
}

func getValidationErrorText(_ error: ValidationError) -> String {
    switch error {
    case .missingUsername:
        return NSLocalizedString("signin.error.missing_username", comment: "Validation error indicating the username field is missing")
    case .missingPassword:
        return NSLocalizedString("signin.error.missing_password", comment: "Validation error indicating the password field is missing")
    case .missingCredentials:
        return NSLocalizedString("signin.error.missing_credentials", comment: "Validation error indicating both fields are missing")
    case .invalidCredentials:
        return NSLocalizedString("signin.error.invalid_credentials", comment: "Error message for invalid credentials")
    default:
        return ""
    }
}


@ViewBuilder private func getStatusBanner(status: AppModel.GlobalStatus, errorMessage: String) -> some View {
    if status == .noConnectivity {
        withAnimation {
            GlobalStatusView(message: NSLocalizedString("status.error.connectivity", comment: "Error message indicating no internet connection"), kind: .error)
        }
    } else if status == .signedOutSuccessfully {
        withAnimation {
            GlobalStatusView(message: NSLocalizedString("signin.status.signout", comment: "Confirmation indicating user has signed out"), kind: .success)
        }
    } else if errorMessage != "" {
        withAnimation {
            GlobalStatusView(message: errorMessage, kind: .error)
        }
    } else {
        EmptyView()
    }
}

// MARK: Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AppState(current: .signin))
            .environmentObject(AppModel())
    }
}
