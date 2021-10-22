//
//  MessageDataViewModel.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

struct MediaUploadStatus {

    let totalBytes: Int
    let bytesUploaded: Int
    let url: URL?
    
    var percentage: Double {
        if totalBytes == 0 {
            return 0
        }
        let pct = round(Double(bytesUploaded) / Double(totalBytes) * 100)
        return pct
    }

    static func from(mediaProperties: MediaMessageProperties) ->  MediaUploadStatus {
        return MediaUploadStatus(
            totalBytes: mediaProperties.messageSize ,
            bytesUploaded: mediaProperties.uploadedSize,
            url: mediaProperties.mediaURL
        )
    }
}

class MessageDataListItem: MessageListItemCell {

    // MARK: -Properties
    let sid: String?
    let conversationSid: String?
    let messageUuid: String
    let index: UInt
    var direction: MessageDirection
    let author: String
    let body: String?
    let dateCreated: TimeInterval
    let sendStatus: MessageSendStatus
    let type: TCHMessageType
    let reactions: [ReactionViewModel]
    let mediaSid: MediaSid?
    var mediaProperties: MediaUploadStatus?
    var mediaStatus: MediaStatus?

    var itemType: MessagesTableCellViewType {
        get {
            if (type ==  .text) {
                if direction == .incoming {
                    return .incomingMessage
                } else {
                    return .outgoingMessage
                }
            } else {
                if direction == .incoming {
                    return .incomingMediaMessage
                } else {
                    return .outgoingMediaMessage
                }
            }
        }
    }

    // MARK: - Intialization
    init(item: MessageDataItem) {
        self.sid = item.sid
        self.index = item.index
        self.direction = item.direction
        self.author = item.author
        self.body = item.body
        self.dateCreated = item.dateCreated
        self.sendStatus = item.sendStatus
        self.conversationSid = item.conversationSid
        self.type = item.type
        self.messageUuid = item.uuid
        self.mediaSid = item.mediaSid
        self.reactions = item.reactions.convertToViewModelArray()
        if let media = item.mediaProperties {
            mediaProperties = MediaUploadStatus.from(mediaProperties: media)
        }
        self.mediaStatus = item.mediaStatus
    }
}

fileprivate extension MessageReactionsModel {

    func convertToViewModelArray() -> [ReactionViewModel] {
        var reactionsArray = [ReactionViewModel]()
        for (reaction, count) in reactionsCount {
            let reactionVM = ReactionViewModel(reactionSymbol: reaction.rawValue, reactionCount: count)
            reactionsArray.append(reactionVM)
        }
        return reactionsArray
    }
}
