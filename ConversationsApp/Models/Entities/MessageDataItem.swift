//
//  MessageDataItem.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

struct MediaMessageProperties: Equatable {
    let mediaURL: URL?
    let messageSize: Int
    let uploadedSize: Int
}

enum MediaStatus: Int{
    case downloading, downloaded, error, uploading, uploaded
}

// TODO: make struct
class MessageDataItem {

    var sid: String?
    let uuid: String
    var conversationSid: String?
    var index: UInt
    var direction: MessageDirection
    let author: String
    let body: String?
    var dateCreated: TimeInterval
    var sendStatus: MessageSendStatus
    let type: TCHMessageType
    var reactions: MessageReactionsModel
    var mediaSid: MediaSid?
    var mediaProperties: MediaMessageProperties? = nil
    var mediaStatus:  MediaStatus?

    var attributesDictionnary: [String: Any] {
        return [
            "uuid": self.uuid,
            "reactions": self.reactions.serializedDictionary
        ]
    }

    init(sid: String? = nil,
         uuid: String,
         index: UInt = 0,
         direction: MessageDirection,
         author: String,
         body: String?,
         dateCreated: TimeInterval,
         sendStatus: MessageSendStatus,
         conversationSid: String? = nil,
         type: TCHMessageType,
         mediaSid: MediaSid? = nil,
         reactions: MessageReactionsModel = MessageReactionsModel(),
         mediaProperties: MediaMessageProperties? = nil,
         mediaStatus: MediaStatus? = nil
         )
    {
        self.sid = sid
        self.uuid = uuid
        self.index = index
        self.direction = direction
        self.author = author
        self.body = body
        self.dateCreated = dateCreated
        self.sendStatus = sendStatus
        self.conversationSid = conversationSid
        self.type = type
        self.reactions = reactions
        self.mediaProperties = mediaProperties
        self.mediaSid = mediaSid
        self.mediaStatus = mediaStatus
    }
}

enum MessageDirection: Int {
    case incomming = 0
    case outgoing = 1
}

enum MessageSendStatus: Int {
    case undefined = 0
    case error = 1
    case sending = 2
    case sent = 3
}
