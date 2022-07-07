//
//  AddParticipantsButton.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/2/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct AddParticipantsButton: View {
    
    @State private var showActionSheet: Bool = false
    @State private var selectedType: ParticipantType?
    
    @State var showingAddParticipantSheet: Bool = false
    @State var addParticipantFlow: AddParticipantFlow = .sms
    
    var body: some View {
        VStack(alignment: .center) {
            Text("conversation.empty.title")
                .foregroundColor(Color("WeakTextColor"))
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
            Button(action: addParticipantsAction) {
                Text("participant.add.title")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color("LinkTextColor"))
                    .padding(.all)
                    .frame(minWidth: 140, maxWidth: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color("LinkTextColor"),
                                    lineWidth: 2)
                    )
            }
            .padding(.top, 16)
            .actionSheet(isPresented: $showActionSheet, content: {
                return getAddParticipantActionSheet(selectedType: $selectedType, tapActionSheetItem: tapActionSheetItem)
            })
            .sheet(isPresented: $showingAddParticipantSheet) {
                AddParticipantSheet(isPresented: $showingAddParticipantSheet, flow: $addParticipantFlow)
            }
        }
    }
    
    // MARK: - Actions
    func addParticipantsAction() {
        showActionSheet = true
    }
    
    func tapActionSheetItem(_ flow: AddParticipantFlow) {
        addParticipantFlow = flow
        showingAddParticipantSheet.toggle()
    }
}

func getAddParticipantActionSheet(selectedType: Binding<ParticipantType?>, tapActionSheetItem: ((_ flow: AddParticipantFlow) -> Void)?) -> ActionSheet {
    let smsAction = ActionSheet.Button.default(Text("participant.type.smsParticipant")) {
        selectedType.wrappedValue = ParticipantType(name: "participant.type.sms")
        tapActionSheetItem?(.sms)
    }
    let whatsappAction = ActionSheet.Button.default(Text("participant.type.whatsappParticipant")) {
        selectedType.wrappedValue = ParticipantType(name: "participant.type.whatsapp")
        tapActionSheetItem?(.whatsapp)
    }
    let chatAction = ActionSheet.Button.default(Text("participant.type.chatParticipant")) {
        selectedType.wrappedValue = ParticipantType(name: "participant.type.chat")
        tapActionSheetItem?(.chat)
    }
    let cancelAction = ActionSheet.Button.cancel()
    
    return ActionSheet(title: Text("participant.add.title")
                        .font(.headline),
                        buttons: [smsAction, whatsappAction, chatAction, cancelAction])
}

struct ParticipantType: Identifiable {
    var id: String { name }
    let name: String
}

struct AddParticipantsButton_Previews: PreviewProvider {
    static var previews: some View {
        AddParticipantsButton()
            .frame(width: .infinity)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
