//
//  ConversationsItemListView.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-03.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct ConversationItemsListView: View {
    var items: [PersistentConversationDataItem]
    @Binding var searchText: String
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    @EnvironmentObject var conversationManager: ConversationManager
    @State private var showingLeaveConversationDialog = false
    
    @State var selectedConversationForDeletion: PersistentConversationDataItem? = nil
    
    var filteredConversations: [PersistentConversationDataItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter {
                $0.uniqueName?.localizedCaseInsensitiveContains(searchText) ?? false || $0.friendlyName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        if(filteredConversations.isEmpty){
            NoSearchResultsView()
        } else {
            List(filteredConversations) { model in
                ConversationRowItem(conversation: model, navigationHelper: _navigationHelper)
                .listRowSeparatorTint(Color("LightBorderColor"))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) { // MARK: ios 15+
                    Button(role: .destructive) { // MARK: ios 15+
                        selectedConversationForDeletion = model
                        showingLeaveConversationDialog = true
                        NSLog("Showing dialog")
                    } label: {
                        Label("Leave", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .searchable(text: $searchText)
                    
                    Button {
                        conversationManager.toggleMute(onConversation: model)
                    } label: {
                        if model.muted {
                            Label("Unmute", systemImage: "bell")
                        } else {
                            Label("Mute", systemImage: "bell.slash")
                        }
                    }
                    .tint(Color("PrimaryBackgroundColor")) // MARK: ios 15+
                }
                .alert(isPresented: $showingLeaveConversationDialog) {
                    let title = NSLocalizedString("leave.confirmation.title", comment: "Title for confirming that the user wants to leave this conversation")
                    return Alert(
                        title: Text(title),
                        message: Text("leave.confirmation.description"),
                        primaryButton: .default(Text("Cancel"), action: {}),
                        secondaryButton: .destructive(Text("leave.confirmation.action"), action: {
                            if let selectedConversation = selectedConversationForDeletion {
                                conversationManager.leave(conversation: selectedConversation)
                                selectedConversationForDeletion = nil
                            }
                        })
                    )
                }
            }
            .listStyle(InsetListStyle())
            .refreshable { // MARK: This only works for iOS 15+
                conversationManager.subscribeConversations(onRefresh: true)
            }
        }
    }
}

struct ConversationRowItem: View {
    var conversation: PersistentConversationDataItem
    @StateObject var messageListViewModel = MessageListViewModel()
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    var body: some View {
        NavigationLink(destination: MessageListView(conversation: conversation, viewModel: messageListViewModel),
                       tag: "MessageList-\(conversation.sid ?? "")",
                       selection: $navigationHelper.currentScreen) {
            ConversationListItem(viewModel: conversation)
                .frame(minHeight: 60)
        }
    }
}
