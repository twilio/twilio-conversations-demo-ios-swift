//
//  SigningInCard.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-08.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct SigningInCard: View {
    var body: some View {
        VStack {
            ProgressView()
                .padding(.top, 24)
                .padding(.bottom, 4)
            Text("signin.inprogress.message")
                .frame(maxWidth: .infinity)
                .font(Font.system(size: 14, weight: .medium))
                .lineSpacing(20)
                .foregroundColor(Color("WeakTextColor"))
                .padding(.bottom, 24)
        }
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(Color.incomingMessageBackgroundColor))
        .padding()
    }
}

struct SigningInCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BrandBackgroundColor").edgesIgnoringSafeArea(.all)
            SigningInCard()
        }
    }
}
