//
//  ReactionsPanel.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/22/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI


struct ReactionsPanel: View {
    @EnvironmentObject var appModel: AppModel
    @ObservedObject var viewModel: MessageBubbleViewModel
    var tapReactionAction: (() -> Void)?

    var body: some View {
        HStack {
            ForEach(ReactionType.allCases) { reaction in
                Button(action: { onTapReaction(reaction)} ) {
                    Text(reaction.rawValue)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(viewModel.includesReactionForCurrentUser(reaction) ? Color("PrimaryBackgroundColor") : Color("BodyBackgroundColor"))
                        )
                }
            }
        }
    }
    
    // MARK: - Actions
    func onTapReaction(_ reactionType: ReactionType) {
        viewModel.toggleReaction(reactionType, forIdentity: appModel.myIdentity)
        tapReactionAction?()
    }
    
    init(_ model: MessageBubbleViewModel, tapReactionAction: @escaping (() -> Void) = {}) {
        self.viewModel = model
        self.tapReactionAction = tapReactionAction
    }
}

struct ReactionsPanel_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let bubbles: [PersistentMessageDataItem.Decode] = load("testMessages.json")
        let currentUser = "user01"
        let managedObjectContext = appModel.getManagedContext()

        // Message with reactions
        ReactionsPanel(MessageBubbleViewModel(message: bubbles[5].message(inContext: managedObjectContext), currentUser: currentUser))
            .environmentObject(appModel)

        // Message without reactions
        ReactionsPanel(MessageBubbleViewModel(message: bubbles[0].message(inContext: managedObjectContext), currentUser: currentUser))
            .environmentObject(appModel)
    }
}
