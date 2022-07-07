//
//  PasswordVisibilityToggle.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-09.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct PasswordVisibilityToggle: View {
    @Binding var showPassword: Bool
    
    var body: some View {
        Button(action: { showPassword = !showPassword }) {
            Image(systemName: showPassword ? "eye.slash" : "eye")
                .resizable()
                .frame(width: 24, height: 16, alignment: .leading)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(Color("LinkIconColor"))
                .tint(.blue)
        }
    }
}

struct PasswordVisibilityToggle_Previews: PreviewProvider {
    @State static var hidePassword: Bool = false
    @State static var showPassword: Bool = true
    
    static var previews: some View {
        VStack {
            PasswordVisibilityToggle(showPassword: $hidePassword)
            Spacer()
                .frame(height: 48)
            PasswordVisibilityToggle(showPassword: $showPassword)
        }
    }
}
