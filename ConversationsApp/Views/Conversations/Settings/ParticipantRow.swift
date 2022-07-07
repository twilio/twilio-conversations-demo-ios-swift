//
//  ParticipantRow.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-14.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct ParticipantRow: View {
    let name: String
    
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack(spacing: 0.0) {
                HStack(alignment: .center) {
                    ParticipantRowDetails(name: name)
                    Spacer()
                }
                Divider()
                    .background(Color("LightBorderColor"))
                    .padding(.leading, 56.0)
            }
       }
    }
}

struct DefaultAvatar: View {
    var size: CGFloat = 32.0
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("UserBackgroundColor"))
            Image(systemName: "person")
                .resizable(capInsets: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8), resizingMode: Image.ResizingMode.stretch)
                .frame(width: size/2, height: size/2, alignment: .center)
                .foregroundColor(Color("TextColor"))
        }
        .frame(width: size, height: size)
    }
}

struct ParticipantRowDetails: View {
    var name: String
    
    var body: some View {
        DefaultAvatar()
            .padding(12.0)
        Text(name)
            .font(Font.system(size: 16.0))
            .foregroundColor(Color("TextColor"))
    }
}

struct ParticipantRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("BrandBackgroundColor").edgesIgnoringSafeArea(.all)
            VStack(spacing: 0.0) {
                ParticipantRow(name: "Rob")
                ParticipantRow(name: "+1 1234567890")
                AddParticipantRow()
            }
            .background(.white)
        }
    }
}
