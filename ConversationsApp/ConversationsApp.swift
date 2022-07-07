//
//  ConversationsApp.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 02.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

@main // MARK: ios 14+
struct ConversationsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    static let navigationHelper = NavigationHelper()

    @StateObject private var model: AppModel // MARK: ios 14+

    init(appModel: AppModel) {
        _model = StateObject(wrappedValue: appModel)
    }

    init() {
        _model = StateObject(wrappedValue: AppModel.shared)
    }

    var body: some Scene { // MARK: ios 14+
        WindowGroup { // MARK: ios 14+
            MainView()
                .environment(\.managedObjectContext, model.getManagedContext())
                .environmentObject(model)
                .environmentObject(ConversationsApp.navigationHelper)
                .environmentObject(model.conversationManager)
                .environmentObject(model.messagesManager)
                .environmentObject(model.participantsManager)
        }
    }
}
