//
//  CreateConversationView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 03.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct CreateConversationView: View {
    @EnvironmentObject var conversationManager: ConversationManager
    
    @State var conversationTitle = ""
    @State var errorText = ""
    @State var createButtonDisabled = false
    
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                let title = NSLocalizedString("conversation.create.field_name", comment: "Title for the conversation name field")
                let placeholder = NSLocalizedString("conversation.create.placeholder", comment: "Placeholder for the conversation name field")
                InputField(text: $conversationTitle, error: $errorText, title: title, description: "", prefix: "", placeholder: placeholder, keyboardType: .default)
                
                Spacer()
            }
            .navigationBarTitle(Text("conversation.create.title"), displayMode: .inline)
            .navigationBarWith(backgroundColor: UIColor.lightBackgroundColor, tintColor: UIColor.textColor)
            .navigationBarItems(leading: Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .navigationBarItems(trailing: createButtonDisabled ? AnyView(ProgressView()) : AnyView(Button(action: {
                if conversationTitle.isEmpty {
                    errorText = NSLocalizedString("conversation.create.empty.description", comment: "Inline error message for a blank or missing conversation name")
                    return
                }
                
                createConversation() {
                    withAnimation {
                        isPresented.toggle()
                    }
                }
            }) {
                Text("conversation.create.action")
                    .foregroundColor(Color("LinkTextColor"))
            }))
        }
    }

    private func createConversation(completion: @escaping () -> ()) {
        createButtonDisabled = true

        conversationManager.createAndJoinConversation(friendlyName: conversationTitle) { (error) in
            createButtonDisabled = false
            if let error = error {
                self.errorText = error.localizedDescription
            } else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}

struct CreateConversationView_Previews: PreviewProvider {
    @State static var isPresented: Bool = true

    static var previews: some View {
        CreateConversationView(isPresented: $isPresented)
    }
}
