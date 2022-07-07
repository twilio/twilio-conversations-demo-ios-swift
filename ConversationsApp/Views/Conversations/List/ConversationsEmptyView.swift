//
//  ConversationsEmptyView.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-03.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct ConversationsEmptyView: View {
    @Binding var showingCreateConversationSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("conversations.empty.title")
                .font(.system(size: 20, weight: .bold))
            Text("conversations.empty.description")
                .font(.system(size: 16))
                .foregroundColor(Color.textWeak)
                .padding(EdgeInsets(top: 4, leading: 16, bottom: 16, trailing: 16))
            Button(action: {
                showingCreateConversationSheet.toggle()
            }) {
                Text("conversations.empty.action")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .background(Color.primaryBackgroundColor)
            .foregroundColor(Color.white)
            .cornerRadius(4)
            Spacer()
        }
    }
}
