//
//  UsernameField.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-08.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct UsernameField: View {
    @Binding var login: String
    var hasValidationError: Bool = false
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: login.isEmpty ? .leading : .trailing, vertical: .center)) {
            TextField("signin.placeholder.username", text: $login)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .font(Font.system(size: 16.0))
                .foregroundColor(Color("TextColor"))
                
            
            if !login.isEmpty {
                Button(action: { login = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .leading)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(Color("TextIconColor"))
                        .tint(.blue)
                }
            }
        }
        .padding(.top, 24)
        .padding()

        Divider()
            .background(hasValidationError ? Color("ErrorBorderColor") : Color("LightBorderColor"))
            .padding(.leading , 16)
    }
}

struct UsernameField_Previews: PreviewProvider {
    @State private static var username: String = ""
    @State private static var username2: String = "Fred"

    static var previews: some View {
        VStack {
            UsernameField(login: $username)
            UsernameField(login: $username2)
            UsernameField(login: $username2, hasValidationError: true)
        }
    }
}
