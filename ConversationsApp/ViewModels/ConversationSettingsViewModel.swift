//
//  ConversationSettingsViewModel.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-03-10.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation

final class ConversationSettingsViewModel: ObservableObject, Identifiable {
    // ConversationEvents
    @Published var currentConversationEvent: ConversationEvent? = nil
    
    // MARK: Conversation Events
    func registerForConversationEvents(_ event: ConversationEvent) {
        DispatchQueue.main.async {
            self.currentConversationEvent = event
            
            DispatchQueue.main.asyncAfter(deadline: .now() + GlobalStatusView.ttl) {
                self.currentConversationEvent = nil
            }
        }
    }
}
