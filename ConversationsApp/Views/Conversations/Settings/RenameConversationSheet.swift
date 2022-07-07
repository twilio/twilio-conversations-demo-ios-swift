//
//  RenameConversationSheet.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-03-14.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI
import TwilioConversationsClient

struct RenameConversationSheet: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var conversationManager: ConversationManager

    @Binding var isPresented: Bool
    
    @State var name: String
    @State var nameFieldError = ""
    
    @State var alertError: Error? = nil
    @State var showingAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                let title = NSLocalizedString("conversation.settings.rename.name.title", comment: "Title for the conversation name field")
                let placeholder = NSLocalizedString("conversation.settings.rename.name.placeholder", comment: "Placeholder for the conversation name field")
                InputField(text: $name, error: $nameFieldError, title: title, description: "", prefix: "", placeholder: placeholder, keyboardType: .default)
                
                Spacer()
            }
            .navigationBarTitle(Text("conversation.settings.rename.title"), displayMode: .inline)
            .navigationBarWith(backgroundColor: UIColor.lightBackgroundColor, tintColor: UIColor.textColor)
            .navigationBarItems(leading: Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .navigationBarItems(trailing: Button(action: {
                if let conversationSid = appModel.selectedConversation?.sid {
                    if name.isEmpty {
                        nameFieldError = NSLocalizedString("conversation.settings.rename.name.error_blank", comment: "Inline error message for a blank or missing conversation name")
                        return
                    }
                    
                    conversationManager.renameConversation(sid: conversationSid, name: name) { (error) in
                        if let error = error {
                            alertError = error
                            showingAlert.toggle()
                        } else {
                            isPresented.toggle()
                        }
                    }
                }
            }) {
                Text("conversation.settings.rename.action")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .alert(isPresented: $showingAlert) {
                if let alertError = alertError as? TCHError {
                    let description = String(format: NSLocalizedString("conversation.settings.rename.error.description", comment: "Generic error description containing both the error code and error message"), String(alertError.code), alertError.localizedDescription)
                    return Alert(title: Text("conversation.settings.rename.error.title"), message: Text(description), dismissButton: .default(Text("dialog.close"), action: {}))
                }
                
                let description = alertError?.localizedDescription ?? ""
                return Alert(title: Text(""), message: Text(description), dismissButton: .default(Text("dialog.close"), action: {}))
            }
        }
    }
}

struct RenameConversationSheet_Previews: PreviewProvider {
    @State static var isPresented: Bool = true

    static var previews: some View {
        RenameConversationSheet(isPresented: $isPresented, name: "Test Conversation")
    }
}
