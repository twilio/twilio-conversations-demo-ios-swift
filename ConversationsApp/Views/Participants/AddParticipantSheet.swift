//
//  AddParticipantSheet.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-03-02.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI
import TwilioConversationsClient

enum AddParticipantFlow: String {
    case sms = "SMS"
    case whatsapp = "WhatsApp"
    case chat = "Chat"
}

struct AddParticipantSheet: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var participantsManager: ParticipantsManager
    
    @Binding var isPresented: Bool
    @Binding var flow: AddParticipantFlow
    
    @State var primaryFieldValue = ""
    @State var primaryFieldError = ""
    @State var proxyNumber = ""
    @State var proxyNumberError = ""
    @State var error = ""
    @State var addButtonDisabled = false
    
    @State var alertError: Error? = nil
    @State var showingAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                let primaryFieldTitle = getPrimaryFieldTitleFor(flow)
                let primaryFieldDescription = getPrimaryFieldDescriptionFor(flow)
                let prefix = getPrimaryFieldPrefixFor(flow)
                let placeholder = getPrimaryFieldPlaceholderFor(flow)
    
                InputField(text: $primaryFieldValue, error: $primaryFieldError, title: primaryFieldTitle, description: primaryFieldDescription, prefix: prefix, placeholder: placeholder, keyboardType: requiresProxyNumber(flow) ? .phonePad : .default)
                
                if (requiresProxyNumber(flow)) {
                    let proxyFieldTitle = NSLocalizedString("participant.add.proxy.title", comment: "Title for the proxy phone number field")
                    let proxyFieldDescription = NSLocalizedString("participant.add.proxy.description" , comment: "Description that clarifies what the proxy phone number is")
                    InputField(text: $proxyNumber, error: $proxyNumberError, title: proxyFieldTitle, description: proxyFieldDescription, prefix: prefix, placeholder: placeholder, keyboardType: .phonePad)
                }
                    
                if (!error.isEmpty) {
                    Text(error)
                        .font(Font.system(size: 14))
                        .foregroundColor(Color("ErrorTextColor"))
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16))
                }
                
                Spacer()
            }
            .navigationBarTitle(Text(getTitleFor(flow)), displayMode: .inline)
            .navigationBarWith(backgroundColor: UIColor.lightBackgroundColor, tintColor: UIColor.textColor)
            .navigationBarItems(leading: Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .navigationBarItems(trailing: addButtonDisabled ? AnyView(ProgressView()) : AnyView(Button(action: {
                if let conversationSid = appModel.selectedConversation?.sid {
                    addButtonDisabled = true

                    if (flow == .chat) {
                        participantsManager.addChatParticipant(primaryFieldValue, conversation: conversationSid) { (error) in
                            if let error = error {
                                print("Error whilst adding \(primaryFieldValue): \(String(describing: error))")
                                
                                alertError = error
                                showingAlert.toggle()
                                addButtonDisabled = false
                            } else {
                                print("Added \(primaryFieldValue) to conversation successfully")
                                isPresented.toggle()
                            }
                        }
                    } else {
                        participantsManager.addNonChatParticipant(primaryFieldValue, proxyNumber: proxyNumber, participantType: flow, conversation: conversationSid) { (error) in
                            if let error = error {
                                print("Error whilst adding \(primaryFieldValue)/ proxy \(proxyNumber): \(String(describing: error))")
                                
                                alertError = error
                                showingAlert.toggle()
                                addButtonDisabled = false
                            } else {
                                print("Added \(primaryFieldValue)/ proxy \(proxyNumber) to conversation successfully")
                                isPresented.toggle()
                            }
                        }
                    }
                }
            }) {
                Text("Add")
                    .foregroundColor(Color("LinkTextColor"))
            }))

            .alert(isPresented: $showingAlert) {
                if let alertError = alertError as? TCHError {
                    let title = String(format: NSLocalizedString("dialog.error_code.title", comment: "Generic error dialog title with an error code"), String(alertError.code))
                    return Alert(title: Text(verbatim: title), message: Text(alertError.localizedDescription), dismissButton: .default(Text("dialog.close"), action: {}))
                }
                
                let description = alertError?.localizedDescription ?? ""
                return Alert(title: Text(""), message: Text(description), dismissButton: .default(Text("dialog.close"), action: {}))
            }
        }
    }
}

private func getTitleFor(_ flow: AddParticipantFlow) -> String {
    return String(format: NSLocalizedString("participant.add.flow.title", comment: "Modal sheet title for the specific add participant flow"), flow.rawValue)
}

private func getPrimaryFieldTitleFor(_ flow: AddParticipantFlow) -> String {
    switch (flow) {
    case .sms, .whatsapp:
        return String(format: NSLocalizedString("participant.add.non_chat.primary.title", comment: "Title for the username field when adding a non-Chat participant"), flow.rawValue)
    case .chat:
        return NSLocalizedString("participant.add.chat.primary.title", comment: "Title for the username field when adding a Chat participant")
    }
}

private func getPrimaryFieldDescriptionFor(_ flow: AddParticipantFlow) -> String {
    let key = "participant.add.\(flow).primary.description"
    return NSLocalizedString(key, comment: "Description for the primary field clarifying what the number or username is")
}

private func getPrimaryFieldPrefixFor(_ flow: AddParticipantFlow) -> String {
    switch (flow) {
    case .sms:
        return "+"
    case .whatsapp:
        return "whatsapp: +"
    default:
        return ""
    }
}

private func getPrimaryFieldPlaceholderFor(_ flow: AddParticipantFlow) -> String {
    switch (flow) {
    case .sms, .whatsapp: return "123456789012"
    case .chat: return "example username"
    }
}

private func requiresProxyNumber(_ flow: AddParticipantFlow) -> Bool {
    return flow == .whatsapp || flow == .sms
}

struct AddParticipantSheet_Previews: PreviewProvider {
    @State static var isPresented: Bool = true
    @State static var flow: AddParticipantFlow = .sms
    
    static var previews: some View {
        AddParticipantSheet(isPresented: $isPresented, flow: $flow)
    }
}
