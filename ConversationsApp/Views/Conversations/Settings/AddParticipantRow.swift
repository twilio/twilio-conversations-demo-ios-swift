//
//  AddParticipantRow.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-15.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct AddParticipantRow: View {
    @State private var showActionSheet: Bool = false
    @State private var selectedType: ParticipantType?
    
    var tapActionSheetItem: ((_ flow: AddParticipantFlow) -> Void)?
    
    var body: some View {
        Button(action: addParticipant) {
            VStack(spacing: 0.0) {
                HStack(alignment: .center) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundColor(Color("LinkIconColor"))
                        .frame(width: 22.0, height: 22.0)
                        .padding(17.0)
                    
                    Text("conversation.settings.empty.action")
                        .font(Font.system(size: 16.0))
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color("LightBorderColor"))
                    .padding(.leading, 56.0)
                    
            }
        }
        .actionSheet(isPresented: $showActionSheet, content: {
            return getAddParticipantActionSheet(selectedType: $selectedType, tapActionSheetItem: tapActionSheetItem)
        })
    }
    
    // MARK: - Actions

    func addParticipant() {
        showActionSheet = true
    }
}

struct AddParticipantRow_Previews: PreviewProvider {
    static var previews: some View {
        AddParticipantRow()
    }
}
