//
//  LoadingView.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-03.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    var body: some View {
        HStack {
            ProgressView()
            Text("loading.text")
                .font(.system(size: 14))
                .foregroundColor(Color.textWeak)
                .padding(.leading, 6)
        }
    }
}
