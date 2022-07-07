//
//  MessageDataItem.swift
// TODO: rename and move
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

enum MediaStatus: Int {
    case unknown, downloading, downloaded, error, uploading, uploaded
}

enum MessageDirection: Int, Codable {
    case incoming = 0, outgoing
}
