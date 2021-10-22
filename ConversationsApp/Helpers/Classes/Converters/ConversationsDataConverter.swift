//
//  ConversationDataConverter.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import TwilioConversationsClient

class ConversationsDataConverter: MessageDataConverterProtocol {

    func convert(message: TCHMessage) -> MessageDataItem? {
        guard let messageSid = message.sid, let uuid = message.attributes()?.toStringBasedDictionary()["uuid"] as? String else {
            return nil
        }
        return MessageDataItem(sid: messageSid,
                               uuid: uuid,
                               index: message.index as! UInt,
                               direction: MessageDirection.outgoing,
                               author: message.author ?? "",
                               body: message.body ?? "",
                               dateCreated: message.dateCreatedAsDate?.timeIntervalSince1970 ?? 0,
                               sendStatus: MessageSendStatus.undefined,
                               conversationSid: "",
                               type: message.messageType,
                               mediaSid: message.mediaSid,
                               reactions: MessageReactionsModel.fromAttributes(jsonAttributes: message.attributes()),
                               mediaStatus: .none
                            )
    }
}

extension MessageReactionsModel {

    static func fromAttributes(jsonAttributes: TCHJsonAttributes?) -> MessageReactionsModel {
        var result = MessageReactionsModel()
        if let serialized = jsonAttributes?.dictionary?["reactions"] as? [String: Array<String>] {
            for (reaction, participants) in serialized {
                guard let reactionType = ReactionType.fromAssociatedValue(reaction) else {
                    break
                }
                for (participantId) in participants {
                    result.tooggleReaction(reactionType, forParticipant: participantId)
                }
            }
        }
        print ("MessageReactionModel -> fromAttributes result : \(result)")
        return result
    }
}

