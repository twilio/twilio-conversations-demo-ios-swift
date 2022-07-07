//
//  EditUsernameView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 11.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI
import TwilioConversationsClient

struct EditUsernameView: View {
    @EnvironmentObject var appModel: AppModel

    @Binding var isPresented: Bool
    
    @State var friendlyName: String
    @State var errorText = ""
    
    @State var alertError: Error? = nil
    @State var showingAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                let title = NSLocalizedString("userProfile.edit.title", comment: "Title for the friendly name field")
                let placeholder = NSLocalizedString("userProfile.edit.title", comment: "Placeholder for the friendly name field")
                InputField(text: $friendlyName, error: $errorText, title: title, description: "", prefix: "", placeholder: placeholder, keyboardType: .default)
                
                Spacer()
            }
            .navigationBarTitle(Text("userProfile.edit.title"), displayMode: .inline)
            .navigationBarWith(backgroundColor: UIColor.lightBackgroundColor, tintColor: UIColor.textColor)
            .navigationBarItems(leading: Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .navigationBarItems(trailing: Button(action: {
                if friendlyName.isEmpty {
                    errorText = NSLocalizedString("userProfile.edit.error.empty", comment: "Inline error message for a blank or missing username")
                    return
                }
                
                updateFriendlyName() {
                    withAnimation {
                        isPresented.toggle()
                    }
                }
            }) {
                Text("userProfile.edit.action")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .alert(isPresented: $showingAlert) {
                if let alertError = alertError as? TCHError {
                    let title = String(format: NSLocalizedString("dialog.error_code.title", comment: "Generic error title showing the error code number"), String(alertError.code))
                    return Alert(title: Text(title), message: Text(alertError.localizedDescription), dismissButton: .default(Text("dialog.close"), action: {}))
                }
                
                let description = alertError?.localizedDescription ?? ""
                return Alert(title: Text(""), message: Text(description), dismissButton: .default(Text("dialog.close"), action: {}))
            }
        }
    }
    
    func updateFriendlyName(completion: @escaping () -> ()) {
        appModel.myUser?.setFriendlyName(self.friendlyName, completion: { (result) in
            if let error = result.error {
                self.alertError = error
                showingAlert.toggle()
            } else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        })
    }
}

struct EditUsernameView_Previews: PreviewProvider {
    @State static var isPresented: Bool = true

    static var previews: some View {
        EditUsernameView(isPresented: $isPresented, friendlyName: "Fred")
    }
}
