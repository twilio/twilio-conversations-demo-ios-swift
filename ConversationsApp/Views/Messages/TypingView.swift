//
//  TypingView.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/10/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct TypingView: View {
    var label: String

    var body: some View {
        Text(label)
            .foregroundColor(Color("WeakTextColor"))
            .font(.system(size: 14))
    }
}

struct TypingView_Previews: PreviewProvider {
    static var previews: some View {
        TypingView(label: "2 participants are typing...")
    }
}
