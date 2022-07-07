//
//  EmptyParticipantsSection.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-14.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct EmptyParticipantsSection: View {
    @State private var showActionSheet: Bool = false
    @State private var selectedType: ParticipantType?
    
    @State var showingAddParticipantSheet: Bool = false
    @State var addParticipantFlow: AddParticipantFlow = .sms
    
    var body: some View {
        VStack {
            Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: 20.0, height: 20.0)
                .foregroundColor(Color("TextIconColor"))
            
            Text("conversation.settings.empty.description")
                .font(Font.system(size: 14.0))
                .foregroundColor(Color("WeakTextColor"))
                .padding(.bottom, 8.0)
            
            Button(action: addParticipant) {
                Text("conversation.settings.empty.action")
                    .font(Font.system(size: 14.0, weight: .bold))
                    .padding(EdgeInsets(top: 12.0, leading: 16.0, bottom: 12.0, trailing: 16.0))
            }
            .foregroundColor(Color.white)
            .background(RoundedRectangle(cornerRadius: 4)
            .fill(Color.primaryBackgroundColor))
            .actionSheet(isPresented: $showActionSheet, content: {
                return getAddParticipantActionSheet(selectedType: $selectedType, tapActionSheetItem: tapActionSheetItem)
            })
            .sheet(isPresented: $showingAddParticipantSheet) {
                AddParticipantSheet(isPresented: $showingAddParticipantSheet, flow: $addParticipantFlow)
            }
        }
    }
    
    // MARK: - Actions

    func addParticipant() {
        showActionSheet = true
    }
    
    func tapActionSheetItem(_ flow: AddParticipantFlow) {
        addParticipantFlow = flow
        showingAddParticipantSheet.toggle()
    }
}

struct EmptyParticipantsSection_Previews: PreviewProvider {
    static var previews: some View {
        EmptyParticipantsSection()
    }
}
