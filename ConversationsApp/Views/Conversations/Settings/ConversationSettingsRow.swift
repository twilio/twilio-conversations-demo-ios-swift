//
//  ConversationSettingsRow.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-11.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

enum RowType {
    case normal
    case destructive
}

struct ConversationSettingsRow: View {
    let title: String
    let subtitle: String
    let icon: Image
    var type: RowType = .normal
    
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .center, spacing: 16.0) {
                icon
                    .frame(width: 24, height: 24)
                    .foregroundColor(type == .normal ? Color("LinkIconColor") : Color("ErrorIconColor"))
                
                VStack(spacing: 0.0) {
                    VStack(spacing: 0.0) {
                        Text(title)
                            .font(Font.system(size: 16))
                            .foregroundColor(type == .normal ? Color("TextColor") : Color("ErrorTextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 4.0)
                        Text(subtitle)
                            .font(Font.system(size: 14))
                            .foregroundColor(Color("WeakTextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 10.0)
                    
                    
                    Divider()
                        .background(Color("LightBorderColor"))
                }
            }
            .padding(.leading, 16)
        }
    }
}

struct ConversationSettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BrandBackgroundColor").edgesIgnoringSafeArea(.all)
            VStack(spacing: 0.0) {
                ConversationSettingsRow(title: "Title here", subtitle: "More detailed description here", icon: Image(systemName: "pencil"))
                
                ConversationSettingsRow(title: "Something destructive", subtitle: "More detailed description here", icon: Image(systemName: "bell.slash"), type: .destructive)
            }
            .background(.white)
        }
    }
}
