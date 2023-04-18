//
//  ConversationListView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 28.10.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI
import Combine
import TwilioConversationsClient

struct ConversationsList: View {
    // MARK: Observables
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    @EnvironmentObject var conversationManager: ConversationManager
    
    @StateObject private var viewModel = ConversationListViewModel()
    @State var filtering: Bool = false
    @State var filterQuery: String = ""
    @State private var cancellableSet: Set<AnyCancellable> = []
    @State private var showingCreateConversationSheet: Bool = false
    
    // MARK: View
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack {
                    if filtering {
                        QuickFilter(filterText: $filterQuery, filtering: $filtering)
                            .padding()
                            .background(Color("PrimaryDarkestBackgroundColor"))
                        ConversationItemsListView(items: conversationManager.conversations, searchText: $filterQuery)
                        Spacer()
                    } else if conversationManager.isConversationsLoading {
                        LoadingView()
                    } else {
                        if conversationManager.conversations.isEmpty {
                            if let error = appModel.conversationsError {
                                ConversationsListErrorView(error: error) {
                                    conversationManager.subscribeConversations(onRefresh: false)
                                }
                            } else {
                                ConversationsEmptyView(showingCreateConversationSheet: $showingCreateConversationSheet)
                            }
                        } else {
                            ConversationItemsListView(items: conversationManager.conversations, searchText: $filterQuery)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .onChange(of: filterQuery) { value in
                    NSLog("Setting predicate to '\(value)'")
                }
                .navigationBarTitle(NSLocalizedString("conversations.label", comment: "Title for navigation bar"), displayMode: .inline)
                .navigationBarWith(backgroundColor: UIColor.primaryDarkestBackgroundColor, tintColor: UIColor.inverseTextColor)
                .navigationBarItems(leading: Button(action: {
                    withAnimation {
                        filtering = true
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                })
                .navigationBarItems(trailing:
                    Button(action: {
                        showingCreateConversationSheet.toggle()
                    }
                ){
                    Image("newConversation")
                })
                .sheet(isPresented: $showingCreateConversationSheet) {
                    CreateConversationView(isPresented: $showingCreateConversationSheet)
                }
                .onAppear(perform: {
                    conversationManager.conversationEventPublisher.sink(receiveValue: { conversationEvent in
                        viewModel.registerForConversationEvents(conversationEvent)
                    })
                    .store(in: &cancellableSet)
                })
                
                if appModel.globalStatus == .noConnectivity {
                    withAnimation {
                        GlobalStatusView(message: NSLocalizedString("status.error.connectivity", comment: "Error message indicating no internet connection"), kind: .error)
                    }
                } else {
                    getNotificationStatusBanner(event: viewModel.conversationEvent)
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.inverseTextColor
    }
}

struct ConversationsListErrorView: View {

    var error: TCHError
    var buttonAction: () -> Void

    var body: some View {
        VStack (alignment: .center) {
            Image(systemName: "exclamationmark.square.fill")
                .font(.system(size: 20))
                .foregroundColor(Color("ErrorTextColor"))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
            Text("errorCode \(String(error.code))")
                .font(.system(size: 20, weight: .bold))
            if let errorMessage = error.userInfo["TCHErrorMsgKey"] as? String {
                Text(errorMessage)
                    .font(.system(size: 16))
                    .foregroundColor(Color.textWeak)
                    .padding(EdgeInsets(top: 4, leading: 16, bottom: 16, trailing: 16))
            }
            Button(action: buttonAction, label: {
                Text("conversations.loading_error.buttonText")
                    .font(.system(size: 14, weight: .bold))
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
            })
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .background(Color.primaryBackgroundColor)
            .foregroundColor(Color.white)
            .cornerRadius(4)
        }
    }
}

@ViewBuilder private func getNotificationStatusBanner(event: ConversationEvent?) -> some View {
    switch event {
    case .notificationsTurnedOn:
        withAnimation {
            GlobalStatusView(message: NSLocalizedString("notification.off.label", comment: "Notification indicating that the conversation was successfully muted"), kind: .success)
        }
    case .notificationsTurnedOff:
        withAnimation {
            GlobalStatusView(message: NSLocalizedString("notification.on.label", comment: "Notification indicating that the conversation was successfully unmuted"), kind: .success)
        }
    case .leftConversation:
        withAnimation {
            GlobalStatusView(message: NSLocalizedString("conversation.left.label", comment: "Notification indicating that the user has successfully left the conversation"), kind: .success)
        }
    default:
        EmptyView()
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let items: [PersistentConversationDataItem.Decode] = load("testConversations.json")
        let _ = items.map { $0.conversation(inContext: appModel.getManagedContext()) }
        let navigationHelper = NavigationHelper()
        
        ConversationsList()
            .environmentObject(appModel)
            .environmentObject(appModel.conversationManager)
            .environmentObject(navigationHelper)
    }
}
