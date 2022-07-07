//
//  ConversationListViewModel.swift
//  ConversationsApp
//
//  Created by Sahib Bajaj on 3/7/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI
import TwilioConversationsClient

final class ConversationListViewModel: ObservableObject, Identifiable {
    
    // Conversation Events
    @Published var conversationEvent: ConversationEvent? = nil
    
    // MARK: Conversation Events
    func registerForConversationEvents(_ event: ConversationEvent) {
        DispatchQueue.main.async {
            self.conversationEvent = event
            
            DispatchQueue.main.asyncAfter(deadline: .now() + GlobalStatusView.ttl) {
                self.conversationEvent = nil
            }
        }
    }
    
}
