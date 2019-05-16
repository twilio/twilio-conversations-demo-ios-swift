//
//  ConversationDataConverterProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol ConversationDataConverterProtocol {

    func convert(conversation: TCHConversation) -> ConversationDataItem?
}
