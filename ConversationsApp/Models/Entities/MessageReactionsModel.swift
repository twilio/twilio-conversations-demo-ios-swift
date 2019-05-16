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
    case thumbUp = "👍"
    case thumbDown = "👎"

    var associatedValue: String {
        switch self {
        case .heart:
            return "heart"
        case .laugh:
            return "laugh"
        case .sad:
            return "sad"
        case .thumbUp:
            return "thumbUp"
        case .thumbDown:
            return "thumbDown"
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
        if value == ReactionType.thumbUp.associatedValue {
            return .thumbUp
        }
        if value == ReactionType.thumbDown.associatedValue {
            return .thumbDown
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
    
    mutating func tooggleReaction(recation: ReactionType, forParticipant participant: String) {
        guard var participantSet = reactionDict[recation] else {
            let participants = Set<String>(arrayLiteral: participant)
            reactionDict[recation] = participants
            return
        }
        if (participantSet.contains(participant)) {
            participantSet.remove(participant)
            if (participantSet.isEmpty) {
                reactionDict.removeValue(forKey: recation)
                return
            }
        } else {
            participantSet.insert(participant)
        }
        reactionDict[recation] = participantSet
    }
}
