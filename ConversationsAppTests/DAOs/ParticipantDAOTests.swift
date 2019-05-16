//
//  ParticipantDAOTests.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import XCTest
import CoreData

@testable import ConversationsApp

fileprivate class ParticipantDAOTest: XCTestCase {

    var participantDao: ParticipantDAOImpl!
    let exampleConversationSid = "test-conversation"

    override func setUp() {
        participantDao = ParticipantDAOImpl()
        participantDao.clearData()
    }

    func testOnEmptyTable() {
        let observable = participantDao.getParticipants(inConversation: exampleConversationSid )
        participantDao.clearData()
        XCTAssertEqual(observable.value!.count, 0)
    }

    func testInsertAndGet() {
        participantDao.insertOrUpdateParticipants([buildTestParticipant()])
        let observable = participantDao.getParticipants(inConversation: exampleConversationSid )
        XCTAssert(observable.value?.count == 1)
    }

    func testInsertAndUpdateIsTyping() {
        let participant = buildTestParticipant()
        let observable = participantDao.getParticipants(inConversation: exampleConversationSid )
        participantDao.insertOrUpdateParticipants([participant])

        participant.isTyping = true
        participantDao.insertOrUpdateParticipants([participant])


        XCTAssert(observable.value?.count == 1)
        XCTAssertTrue(observable.value!.first!.isTyping)
    }

    func testInsertAndGetIsTyping() {
        let participant = buildTestParticipant()
        participant.isTyping = true
        participantDao.insertOrUpdateParticipants([participant])
        let observable = participantDao.getTypingParticipants(inConversation: exampleConversationSid)
        XCTAssert(observable.value?.count == 1)
        XCTAssertTrue(observable.value!.first!.isTyping)
    }

    func testUpdateIsTyping() {
        let participant = buildTestParticipant()
        participantDao.insertOrUpdateParticipants([participant])
        let observable = participantDao.getTypingParticipants(inConversation: exampleConversationSid)
        participantDao.updateIsTyping(for: participant.sid, isTyping: true)
        let expectaction = XCTestExpectation(description: "We expect one callback to be called")
        observable.observe(with: self) {participants in
            expectaction.fulfill()
            XCTAssertNotNil(participants)
            XCTAssertTrue(participants!.first!.isTyping)
        }
        wait(for: [expectaction], timeout: 5)
    }

    override func tearDown() {
        participantDao.clearData()
    }

    private func buildTestParticipant() -> ParticipantDataItem {
        return  ParticipantDataItem (
            sid: "a-test-user",
            conversationSid: exampleConversationSid,
            identity: "user-0",
            type: 0,
            attributes: nil,
            isTyping: false
        )
    }
}

