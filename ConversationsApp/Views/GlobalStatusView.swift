//
//  GlobalStatusView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 26.10.2021.
//  Licensed under the MIT License.

import SwiftUI

struct GlobalStatusView: View {
    let message: String
    let kind: Kind
    
    private var image: Image {
        get { kind == .success ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "exclamationmark.square.fill") }
    }
    
    static let ttl: TimeInterval = 1.2

    var body: some View {
        VStack {
            HStack {
                Spacer()
                image
                    .resizable()
                    .frame(width: 24.0, height: 24.0)
                    .foregroundColor( kind == .success ? Color("SuccessIconColor") : .white)
                Text(message)
                    .font(Font.system(size: 14.0, weight: .semibold))
                Spacer()
            }
            .foregroundColor(kind == .success ? Color.textColor : Color.textInverse)
            .padding(.top, 4)
            .padding(.bottom, 4)
        }
        .background(kind == .success ? Color("SuccessBackgroundColor") : Color("ErrorBackgroundColor"))
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
    }
}

enum Kind {
    case error, success
}

struct GlobalStatusView_Previews: PreviewProvider {
    static let message = "Error hello there"
    static let message2 = "Another error there"
    static let kind1: Kind = .success
    static let kind2: Kind = .error

    static var previews: some View {
        VStack {
            GlobalStatusView(message: message, kind: kind1)
            GlobalStatusView(message: message2, kind: kind2)
        }
    }
}
