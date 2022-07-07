//
//  MessageActionRow.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-17.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct MessageActionRow: View {
    let text: String
    let icon: Image
    var rowType: RowType = .normal
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 0.0) {
                HStack(alignment: .center, spacing: 0.0) {
                    icon
                        .foregroundColor(getColor())
                        .frame(width: 22.0, height: 22.0)
                        .padding(16.0)
                    
                    Text(text)
                        .font(Font.system(size: 16.0))
                        .foregroundColor(getColor())
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color("LightBorderColor"))
                    .padding(.leading, 56.0)
            }
        }
    }
    
    private func getColor() -> Color {
        return rowType  == .destructive ? Color("ErrorTextColor") : Color("LinkTextColor")
    }
}

struct MessageActionRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            MessageActionRow(text: NSLocalizedString("message.details.copy", comment: "Action for copying the body of the selected message"), icon: Image(systemName: "doc.on.doc"))
            MessageActionRow(text: NSLocalizedString("message.details.share", comment: "Action for sharing the body or attachments of the selected message"), icon: Image(systemName: "square.and.arrow.up"))
            MessageActionRow(text: NSLocalizedString("message.details.delete", comment: "Action for deleting the selected message"), icon: Image(systemName: "trash"), rowType: .destructive)
        }
    }
}
