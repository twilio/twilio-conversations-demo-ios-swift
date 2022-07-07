//
//  ReactionsDict.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 30.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//
import TwilioConversationsClient

typealias ReactionsDict = [ReactionType: Set<String>]
typealias ReactionsPerParticipant = [String: [ReactionType]]

extension ReactionsDict {
    /// Convert to View representation
    var counts: [String: Int] {
        let result = self.reduce(into: [:]) { result, entry in
            result[entry.key.associatedValue] = entry.value.count
        }
        NSLog("ReactionsDict.counts result: \(result)")
        return result
    }

    /// Convert to dictionary representation for json serialization
    var serializedDictionary: [String: [String]] {
        return self.reduce(into: [:]) { result, entry in
            result[entry.key.associatedValue] = Array(entry.value)
        }
    }

    func includesReaction(_ reaction: ReactionType, forParticipant participant: String) -> Bool {
        guard let participantSet = self[reaction] else {
            return false
        }
        guard participantSet.contains(participant) else {
            return false
        }
        return true
    }
    
    func includesReactionFrom(participant: String) -> Bool {
        return values.joined().contains(participant)
    }

    mutating func toggleReaction(_ reaction: ReactionType, forParticipant participant: String) {
        guard var participantSet = self[reaction] else {
            let participants = Set<String>(arrayLiteral: participant)
            self[reaction] = participants
            return
        }
        if (participantSet.contains(participant)) {
            participantSet.remove(participant)
            if (participantSet.isEmpty) {
                self.removeValue(forKey: reaction)
                return
            }
            // fallthrough
        } else {
            participantSet.insert(participant)
        }
        self[reaction] = participantSet
    }
    
    func convertToParticipantDictionary() -> ReactionsPerParticipant {
        var reactionsPerParticipant = [String: [ReactionType]]()
        
        for (reaction, participants) in self {
            for participant in Array(participants) {
                if (reactionsPerParticipant[participant]?.append(reaction)) == nil {
                    reactionsPerParticipant[participant] = [reaction]
                }
            }
        }
        return reactionsPerParticipant
    }
}

extension ReactionsDict {
    static func from(attributes attributeString: String?) -> ReactionsDict {
        NSLog("Creating ReactionsDict from attributes string \(String(describing: attributeString))")
        guard let attributes = ReactionsDict.attributeStringToDict(attributeString) else {
            return ReactionsDict()
        }
        NSLog("Creating ReactionsDict from attributes dict \(String(describing: attributes))")
        var result = ReactionsDict()
        if let serialized = attributes["reactions"] as? [String: [String]] {
            for (reaction, participants) in serialized {
                guard let reactionType = ReactionType.fromAssociatedValue(reaction) else {
                    break
                }
                for participantId in participants {
                    result.toggleReaction(reactionType, forParticipant: participantId)
                }
            }
        }
        NSLog("ReactionsDict.from(attributes:) result: \(result)")
        return result
    }

    private static func attributeStringToDict(_ attributes: String?) -> [String: Any]? {
        let data = (attributes ?? "{}").data(using: .utf8)!
        do {
            // JSON attributes could be just a string or a number, we do not support that.
            // Hence, we don't enable .fragmentsAllowed flag so it may fail.
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            }
        } catch {
            NSLog("Failed to parse attributes")
        }
        NSLog("No valid JSON data in attributes serialization")
        return nil
    }

    func toAttributes() -> String? {
        do {
            return String(data: try JSONSerialization.data(withJSONObject: ["reactions": serializedDictionary], options: []), encoding: .utf8)
        } catch {
            return nil
        }
    }
}
