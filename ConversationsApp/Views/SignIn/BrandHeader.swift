//
//  BrandHeader.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-08.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct BrandHeader: View {
    var body: some View {
        VStack {
            Image("conversationsLogo")
                .resizable()
                .frame(width: 42, height: 42)
                .foregroundColor(Color.white)
            Text("Twilio Conversations")
                .foregroundColor(Color("InverseTextColor"))
                .font(Font.system(size: 24.0, weight: .semibold))
                .lineSpacing(32)
            Text("Demo experience")
                .foregroundColor(Color("WeakInverseTextColor"))
                .font(Font.system(size: 18.0))
                .lineSpacing(28)
        }
    }
}

struct BrandHeader_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BrandBackgroundColor").edgesIgnoringSafeArea(.all)
            BrandHeader()
        }
    }
}
