//
//  MessageItemGenerator.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import XCTest
@testable import ConversationsApp
import TwilioConversationsClient

class MessageItemGenerator {

    static func createDiverseMessageList(conversationSid: String) -> [MessageDataItem] {
        let mediaURL = URL(string: "file:///private/var/mobile/Applications/")!

        // Outgoing text
        let outgoingText = MessageDataItem(sid: "0", uuid: "0", direction: .outgoing, author: "0", body: "0", dateCreated: 0, sendStatus: .sending, conversationSid: conversationSid, type: .text)

        let sentText = MessageDataItem(sid: "1", uuid: "1", direction: .outgoing, author: "1", body: "1", dateCreated: 1, sendStatus: .sent, conversationSid: conversationSid, type: .text)

        let failedText = MessageDataItem(sid: "2", uuid: "2", direction: .outgoing, author: "2", body: "2", dateCreated: 2, sendStatus: .error, conversationSid: conversationSid, type: .text)

        let outgoingMedia = MessageDataItem(
            sid: "3", uuid: "3", direction: .outgoing, author: "3", body: "3", dateCreated: 3, sendStatus: .sending, conversationSid: conversationSid, type: .media, mediaSid:"0", mediaProperties: MediaMessageProperties(mediaURL: mediaURL, messageSize: 100, uploadedSize: 100), mediaStatus: .uploaded)

        let sentMedia = MessageDataItem(sid: "4", uuid: "4", direction: .outgoing, author: "4", body: "4", dateCreated: 4, sendStatus: .sent, conversationSid: conversationSid, type: .media)

        let failedMedia = MessageDataItem(sid: "5", uuid: "5", direction: .outgoing, author: "5", body: "5", dateCreated: 5, sendStatus: .error, conversationSid: conversationSid, type: .media)

        // Incomming text
        let receivedText = MessageDataItem(sid: "6", uuid: "6", direction: .incomming, author: "6", body: "6", dateCreated: 6, sendStatus: .sent, conversationSid: conversationSid, type: .text)

        // Incomming media
        let receivedMedia = MessageDataItem(sid: "7", uuid: "7", direction: .incomming, author: "7", body: "7", dateCreated: 7, sendStatus: .sent, conversationSid: conversationSid, type: .media, mediaSid:"0", mediaProperties: MediaMessageProperties(mediaURL: mediaURL, messageSize: 0, uploadedSize: 0), mediaStatus: .downloaded )

        return [outgoingText, sentText, failedText, outgoingMedia, sentMedia, failedMedia, receivedText, receivedMedia]
    }
}
