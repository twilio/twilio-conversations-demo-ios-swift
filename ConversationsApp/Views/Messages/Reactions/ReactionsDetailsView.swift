//
//  ReactionsDetailsView.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/18/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct ReactionsDetailsView: View {
    @StateObject var viewModel: MessageBubbleViewModel
    @Binding var isPresenting: Bool
    
    var tapReactionAction: (() -> Void)?
    
    var body: some View {
        VStack {
            VStack() {
                ActionSheetIndicator()
                    .padding(.bottom, -22)
                Text("reactions.details.view.title")
                    .font(.system(size: 14, weight: .semibold))
                    .padding()
            }
            ReactionsPanel(viewModel, tapReactionAction: onTapReaction)
            
            List(viewModel.reactionDetailList) { reactionRow in
                HStack {
                    HStack() {
                        ParticipantRowDetails(name: reactionRow.identity)
                        Spacer()
                        ForEach(reactionRow.reactions) { reaction in
                            Text(reaction.rawValue)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    
    func onTapReaction() {
        tapReactionAction?()
        isPresenting.toggle()
    }
}

struct ReactionsDetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let bubbles: [PersistentMessageDataItem.Decode] = load("testMessages.json")
        let currentUser = "user01"
        
        let viewModel = MessageBubbleViewModel(message: bubbles[5].message(inContext: appModel.getManagedContext()), currentUser: currentUser)
        ReactionsDetailsView(viewModel: viewModel, isPresenting: Binding.constant(true))
            .environmentObject(appModel)
    }
}
