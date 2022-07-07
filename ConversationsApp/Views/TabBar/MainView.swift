//
//  TabBar.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 02.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI
import Combine

enum CurrentAppState: Hashable {
    case signin
    case main
}

class AppState: ObservableObject {
    @Published var current: CurrentAppState
    
    init(current: CurrentAppState) {
        self.current = current
    }
}

enum Tab: Hashable {
    case conversations
    case profile
    case debug
}

class NavigationHelper : ObservableObject {
    @Published var currentScreen: String? = nil
    @Published var currentTab = Tab.conversations
}

// This is a central view. It shows either a sign in view or a TabBar with available tabs.
struct MainView: View {    
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    init() {
      UITabBar.appearance().unselectedItemTintColor = UIColor.white
      UITabBar.appearance().backgroundColor = UIColor.primaryDarkestBackgroundColor
      UITabBar.appearance().backgroundImage = UIImage()
    }

    @StateObject var appState: AppState = .init(current: .signin)

    // MARK: View
    var body: some View {
        if appState.current == .signin {
            SignInView()
                .environmentObject(appState)
                .transition(.slide)
        } else {
            TabView(selection: $navigationHelper.currentTab) {
                ConversationsList()
                    .tag(Tab.conversations)
                    .tabItem {
                        if navigationHelper.currentTab == Tab.conversations {
                            Image(systemName: "message.fill")
                                .renderingMode(.template)
                        } else {
                            Image(systemName: "message")
                                .renderingMode(.template)
                                .environment(\.symbolVariants, .none)
                        }
                        Text("conversations.label").foregroundColor(Color("InverseTextColor"))
                    }
                UserProfileView()
                    .tag(Tab.profile)
                    .tabItem {
                        if navigationHelper.currentTab == Tab.profile {
                            Image(systemName: "person.fill")
                                .renderingMode(.template)
                        } else {
                            Image(systemName: "person")
                                .renderingMode(.template)
                                .environment(\.symbolVariants, .none)
                        }
                        Text("profile.label").foregroundColor(Color("InverseTextColor"))
                    }
                    .environmentObject(appState)
                DebugView()
                    .tag(Tab.debug)
                    .tabItem {
                        if navigationHelper.currentTab == Tab.debug {
                            Image(systemName: "hammer.fill")
                                .renderingMode(.template)
                        } else {
                            Image(systemName: "hammer")
                                .renderingMode(.template)
                                .environment(\.symbolVariants, .none)
                        }
                        Text("debug.label").foregroundColor(Color("InverseTextColor"))
                    }
            }
            .accentColor(Color(("InverseTextColor")))
            
        }
    }
}
