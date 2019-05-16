//
//  ConversationDataConverterProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

protocol MessageDataConverterProtocol {

    func convert(message: TCHMessage) -> MessageDataItem?
}
