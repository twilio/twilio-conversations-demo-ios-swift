//
//  JsonAttrinutes+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

extension TCHJsonAttributes {

    func toStringBasedDictionary() -> [String:  Any] {
        // At the moment we are using attributes (TCHJsonAttributes) only to store message uuid
        // if needed this method could be updated to return a more complex data structure that is closer
        // to what TCHJsonAttributes can store
        return self.dictionary as? [String: Any] ?? [:]
    }
}
