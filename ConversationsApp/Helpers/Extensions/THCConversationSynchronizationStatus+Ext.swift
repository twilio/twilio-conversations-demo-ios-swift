//
//  THCConversationSynchronizationStatus+Ext.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 10.05.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

extension TCHConversationSynchronizationStatus {

    var asString: String {
        switch self {
        case .all:
            return "all"
        case .failed:
            return "failed"
        case .identifier:
            return "identifier"
        case .metadata:
            return "metadata"
        case .none:
            return "none"
        @unknown default:
            fatalError("@unknown default TCHConversationSynchronizationStatus")
        }
    }
}
