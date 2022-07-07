//
//  ReactionsView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 26.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

// Show existing reactions for a message, based on attributes field "reactions"

// MARK: OneReactionView

struct OneReactionView: View {
    var icon: ReactionType
    var count: Int
    var currentUserReactedToMessage: Bool
    
    var body: some View {
        HStack {
            Text("\(icon.rawValue) \(count)")
                .foregroundColor(currentUserReactedToMessage ? Color("InverseTextColor") : Color("LinkTextColor"))
                .padding(4)
        }
    }
}

// MARK: ReactionsView

struct ReactionsView: View {
    
    @ObservedObject var viewModel: ReactionsViewModel
    var currentUserReactedToMessage: Bool

    var body: some View {
        HStack {
            ForEach(viewModel.reactions, id: \.self) { reaction in
                OneReactionView(icon: ReactionType.fromAssociatedValue(reaction.reaction)!, count: reaction.count, currentUserReactedToMessage: currentUserReactedToMessage)
            }
            
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(currentUserReactedToMessage ? Color("PrimaryBackgroundColor") : Color("BodyBackgroundColor"))
        )
        .shadow(radius: 5)
    }
}

// MARK: Previews

struct ReactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let items: [PersistentMessageDataItem.Decode] = load("testMessages.json")
        let currentUser = "user00"
        let currentUser3 = "user03"
        let currentUserReactedToMessage = true
        let managedObjectContext = appModel.getManagedContext()

        VStack {
            // Long text with reactions
            let messageBubbleViewModel5 = MessageBubbleViewModel(message: items[5].message(inContext: managedObjectContext), currentUser: currentUser).reactions
            ReactionsView(viewModel: ReactionsViewModel(reactions: messageBubbleViewModel5), currentUserReactedToMessage: currentUserReactedToMessage)
                .environmentObject(appModel)

            // Short text with reactions
            let messageBubbleViewModel6 = MessageBubbleViewModel(message: items[6].message(inContext: managedObjectContext), currentUser: currentUser3).reactions
            ReactionsView(viewModel: ReactionsViewModel(reactions: messageBubbleViewModel6), currentUserReactedToMessage: currentUserReactedToMessage)
                .environmentObject(appModel)

            // Image with reactions
            let messageBubbleViewModel7 = MessageBubbleViewModel(message: items[7].message(inContext: managedObjectContext), currentUser: currentUser).reactions
            ReactionsView(viewModel: ReactionsViewModel(reactions: messageBubbleViewModel7), currentUserReactedToMessage: currentUserReactedToMessage)
                .environmentObject(appModel)
            }
 
    
    }
}
