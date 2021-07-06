//
//  MessageReactionsModel.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

enum ReactionType: String, Codable {

    case heart = "❤️"
    case laugh = "😂"
    case sad = "😢"
    case pouting = "😡"
    case thumbsUp = "👍"
    case thumbsDown = "👎"

    var associatedValue: String {
        switch self {
        case .heart:
            return "heart"
        case .laugh:
            return "laugh"
        case .sad:
            return "sad"
        case .pouting:
            return "pouting"
        case .thumbsUp:
            return "thumbs_up"
        case .thumbsDown:
            return "thumbs_down"
        }
    }

    static func fromAssociatedValue(_ value: String) -> ReactionType? {
        if value == ReactionType.heart.associatedValue {
            return .heart
        }
        if value == ReactionType.laugh.associatedValue {
            return .laugh
        }
        if value == ReactionType.sad.associatedValue {
            return .sad
        }
        if value == ReactionType.pouting.associatedValue {
            return .pouting
        }
        if value == ReactionType.thumbsUp.associatedValue {
            return .thumbsUp
        }
        if value == ReactionType.thumbsDown.associatedValue {
            return .thumbsDown
        }
        return nil
    }
}

struct MessageReactionsModel: Encodable {
    
    private(set) var reactionDict = [ReactionType: Set<String>]()

    var reactionsCount: [ReactionType: Int] {
        print("MessageReactionsModel -> reactionsCount in \(reactionDict)")
        let result = reactionDict.reduce(into: [:]) { result, entry in
            result[entry.key] = entry.value.count
        }
        print("MessageReactionsModel -> reactionCount result : \(result)")
        return result
    }

    var serializedDictionary: [String: [String]] {
        var result: [String: [String]] = [:]
        for (key, values) in self.reactionDict {
            result[key.associatedValue] = Array(values)
        }
        return result
    }
    
    mutating func tooggleReaction(_ reaction: ReactionType, forParticipant participant: String) {
        guard var participantSet = reactionDict[reaction] else {
            let participants = Set<String>(arrayLiteral: participant)
            reactionDict[reaction] = participants
            return
        }
        if (participantSet.contains(participant)) {
            participantSet.remove(participant)
            if (participantSet.isEmpty) {
                reactionDict.removeValue(forKey: reaction)
                return
            }
        } else {
            participantSet.insert(participant)
        }
        reactionDict[reaction] = participantSet
    }
}
