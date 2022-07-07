//
//  PersistanceDataAdapter.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/10/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation

/// Abstract:
///     PersistanceDataAdapter provide methods to transform NSManagedObject  from CoreData  to 'Business' types, like Conversation, Particpant.
///
/// Usage:
///   Use PersistanceDataAdapter to transform from 'PersistentConversationDataItem'  model to 'Conversation'.
///
struct PersistanceDataAdapter {
    
    //Transform a 'PersistentConversationDataItem' to 'Conversation' model
    static func transform(from persistentConversation: PersistentConversationDataItem) -> Conversation {
        guard let sid = persistentConversation.sid, !sid.isEmpty else {
            fatalError("PersistentConversationDataItem sid shouldn't be nil.")
        }
        return Conversation(sid: sid)
    }
}
