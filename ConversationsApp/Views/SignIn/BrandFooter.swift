//
//  BrandFooter.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-08.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct BrandFooter: View {
    var body: some View {
        Image("twilioLogo")
            .foregroundColor(Color.white)
    }
}

struct BrandFooter_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BrandBackgroundColor").edgesIgnoringSafeArea(.all)
            BrandFooter()
        }
    }
}
