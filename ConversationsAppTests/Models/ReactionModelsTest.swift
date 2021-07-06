//
//  RecationModelsTest.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import XCTest
import TwilioConversationsClient

@testable import ConversationsApp

fileprivate class ReactionModelTest: XCTestCase {

    func testReactionModelAfterInit() {
        let model = MessageReactionsModel()
        XCTAssertEqual(model.reactionsCount, [:])
    }

    func testRecactionCountAfterAddingHeart() {
        var model = MessageReactionsModel()
        model.tooggleReaction(ReactionType.heart, forParticipant: "test-participant-a")
        let reactionExpected = [ReactionType.heart : 1]
        XCTAssertEqual(reactionExpected, model.reactionsCount)
    }

    func testRecactionCountAfterToggleUnttogle() {
        var model = MessageReactionsModel()
        model.tooggleReaction(ReactionType.heart, forParticipant: "test-participant-a")
        let reactionExpected = [ReactionType.heart : 1]
        XCTAssertEqual(reactionExpected, model.reactionsCount)
        model.tooggleReaction(ReactionType.heart, forParticipant: "test-participant-a")
        XCTAssertEqual(model.reactionsCount, [:])
    }

    func testRecactionCountFor2ParticipantReaction() {
        var model = MessageReactionsModel()
        model.tooggleReaction(ReactionType.heart, forParticipant: "test-participant-a")
        model.tooggleReaction(ReactionType.heart, forParticipant: "test-participant-b")
        XCTAssertEqual(model.reactionsCount, [ReactionType.heart: 2])
    }

    func testCanBeSerialisedEmpty() {
        let model = MessageReactionsModel()
        let expected: [String: Array<String>] = [:]
        XCTAssertEqual(model.serializedDictionary, expected)
    }

    func testCanBeSerialisedWithEntry() {
        var model = MessageReactionsModel()
        model.tooggleReaction(ReactionType.heart, forParticipant: "test-participant-b")
        let expected: [String: Array<String>] = ["heart": ["test-participant-b"]]
        XCTAssertEqual(model.serializedDictionary, expected)
    }

    func testCanConvertFromServer() {
        let fromServer = ["heart": ["test-participant-b"]]
        let dictionnary = TCHJsonAttributes.init(dictionary: ["reactions": fromServer])
        let model = MessageReactionsModel.fromAttributes(jsonAttributes: dictionnary)
        XCTAssertEqual(model.reactionDict, [ReactionType.heart: Set(["test-participant-b"])])
    }

}
