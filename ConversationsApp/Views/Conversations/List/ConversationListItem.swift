//
//  ConversationListItemView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 28.10.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct ConversationListItem: View {
    @ObservedObject var viewModel: PersistentConversationDataItem
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        VStack {
            HStack {
                if viewModel.muted {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextIconColor"))
                    Text(viewModel.title)
                        .lineLimit(1)
                        .font(.system(size: 16))
                        .foregroundColor(Color("WeakTextColor"))
                } else {
                    Text(viewModel.title)
                        .lineLimit(1)
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextColor"))
                }
                Spacer()
                Text(getParticipantCountString(viewModel.participantsCount))
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
            }
            .padding(.bottom, 1)
            HStack {
                if (viewModel.muted) {
                    Text("muted.conversation.label")
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .foregroundColor(Color("WeakTextColor"))
                } else {
                    LastMessageView(viewModel: viewModel)
                }
                
                Spacer()
                Text("\(viewModel.lastMessageDateFormatted)")
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
                if (viewModel.unreadMessagesCount > 0) {
                    Text("\(viewModel.unreadMessagesCount)")
                        .font(.system(size: 14))
                        .padding(.horizontal, 8)
                        .background(Color("PrimaryBackgroundColor"))
                        .foregroundColor(Color.white)
                        .cornerRadius(16)
                }
            }
        }
    }
    
    func getParticipantCountString(_ count: Int64) -> String {
        // empty conversations report back as having 0 participants so round up to 1
        let modifiedCount = max(count, 1)
        let string = modifiedCount == 1 ? "conversation.participant_count.singular" : "conversation.participant_count.plural"
        return String(format: NSLocalizedString(string, comment: "Text stating the number of participants"), "\(modifiedCount)")
    }
}

// Mark: Last Message View
struct LastMessageView: View {
    @ObservedObject var viewModel: PersistentConversationDataItem
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        if(viewModel.lastMessageContentAuthor == appModel.myIdentity){
            //Outgoing message
            switch viewModel.lastMessageContentType {
            case .text:
                Text(viewModel.lastMessagePreview ?? "")
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
            case .image:
                Image(systemName: viewModel.lastMessageContentIcon)
                    .foregroundColor(Color("TextIconColor"))
                    .font(Font.system(size: 16))
                Text("\("You") conversations.image.sharing.label")
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
            default:
                Image(systemName: viewModel.lastMessageContentIcon)
                    .foregroundColor(Color("TextIconColor"))
                    .font(Font.system(size: 16))
                Text("\("You") conversations.file.sharing.label")
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
            }
        } else {
            //Incoming message
            switch viewModel.lastMessageContentType {
            case .text:
                Text(viewModel.lastMessagePreview ?? "")
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
            case .image:
                Image(systemName: viewModel.lastMessageContentIcon)
                    .foregroundColor(Color("TextIconColor"))
                    .font(Font.system(size: 16))
                Text("\(viewModel.lastMessageContentAuthor) conversations.image.sharing.label")
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
            default:
                Image(systemName: viewModel.lastMessageContentIcon)
                    .foregroundColor(Color("TextIconColor"))
                    .font(Font.system(size: 16))
                Text("\(viewModel.lastMessageContentAuthor) conversations.file.sharing.label")
                    .lineLimit(1)
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
            }
        }
    }
}

struct ConversationListItem_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let bubbles: [PersistentConversationDataItem.Decode] = load("testConversations.json")
        let managedObjectContext = appModel.getManagedContext()
        
        List {
            ForEach(0..<100) { n in
                ConversationListItem(viewModel: bubbles[0].conversation(inContext: managedObjectContext))
                ConversationListItem(viewModel: bubbles[1].conversation(inContext: managedObjectContext))
                ConversationListItem(viewModel: bubbles[2].conversation(inContext: managedObjectContext))
            }
        }
        .previewLayout(.fixed(width: 400, height: 700))
        .environmentObject(appModel)
    }
}
