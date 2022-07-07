//
//  PasswordField.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-08.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @State var showPassword = false
    var hasValidationError: Bool = false

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
            if showPassword {
                TextField(NSLocalizedString("signin.placeholder.password", comment: "Placeholder text for password"), text: $password)
                    .font(Font.system(size: 16.0))
                    .foregroundColor(Color("TextColor"))
            } else {
                SecureField(NSLocalizedString("signin.placeholder.password", comment: "Placeholder text for password"), text: $password)
                    .font(Font.system(size: 16.0))
                    .foregroundColor(Color("TextColor"))
            }
            PasswordVisibilityToggle(showPassword: $showPassword)
        }
        .padding()

        Divider()
            .background(hasValidationError ? Color("ErrorBorderColor") : Color("LightBorderColor"))
            .padding(.leading , 16)
    }
}

struct PasswordField_Previews: PreviewProvider {
    @State private static var password: String = ""
    @State private static var password2: String = "secret"

    static var previews: some View {
        VStack {
            PasswordField(password: $password)
            PasswordField(password: $password2)
            PasswordField(password: $password2, showPassword: true)
            PasswordField(password: $password2, showPassword: true, hasValidationError: true)
        }
    }
}
