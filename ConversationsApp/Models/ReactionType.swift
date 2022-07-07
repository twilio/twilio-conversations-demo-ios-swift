//
//  ReactionType.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 30.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

enum ReactionType: String, Codable, CaseIterable, Identifiable {
    var id: String { self.rawValue }

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

    // Provide at least some ordering, not very sensible atm
    static func <(lhs: ReactionType, rhs: ReactionType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
