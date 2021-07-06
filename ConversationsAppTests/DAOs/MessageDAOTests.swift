//
//  MessageDAOTests.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData
import XCTest
@testable import ConversationsApp

fileprivate class MessageDAOTest: XCTestCase {

    private let messagesDAO = MessageDAOImpl()
    private let participantDAO = ParticipantDAOImpl()
    private let reactionDAO = ReactionDAOImpl()
    private let mockedConversationSid = "messageUnitTest"

    override func setUp() {
        messagesDAO.clearData()
        participantDAO.clearData()
        createParticipants(onConversation: mockedConversationSid)
    }

    override func tearDown() {
        messagesDAO.clearData()
        participantDAO.clearData()
    }

    func testUpdateMessageItemByUuid() {
        // Generate test data
        let generatedMessageList = MessageItemGenerator.createDiverseMessageList(conversationSid: mockedConversationSid)

        guard let messageToUpdate = generatedMessageList.first else {
            XCTFail()
            return
        }

        // Insert values into cache
        messagesDAO.upsertMessages(generatedMessageList)

        // Perform body update
        let newBody =  messageToUpdate.body! + "UPDATED"
        let updatedMessage = MessageDataItem(sid: messageToUpdate.sid, uuid: messageToUpdate.uuid, direction: messageToUpdate.direction, author: messageToUpdate.author, body: newBody, dateCreated: messageToUpdate.dateCreated, sendStatus: messageToUpdate.sendStatus, conversationSid: messageToUpdate.conversationSid, type: messageToUpdate.type)
        messagesDAO.upsertMessages([updatedMessage])

        let messagesReceived = expectation(description: "LocalCacheProvider should return message list")

        // Subscribe to lists and check contents
        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)
        messageList.observe(with: self) { list in
            messagesReceived.fulfill()
            XCTAssertEqual(list?.count, generatedMessageList.count)
            XCTAssertEqual(list?.first { $0.uuid == messageToUpdate.uuid }?.body, newBody)
        }

        waitForExpectations(timeout: 1, handler: nil)

        messageList.removeObserver(self)
    }

    func testInsertMessages() {
        // Generate test data
        let generatedMessageList = MessageItemGenerator.createDiverseMessageList(conversationSid: mockedConversationSid)

        // Insert values into cache
        messagesDAO.upsertMessages(generatedMessageList)

        let messagesReceived = expectation(description: "LocalCacheProvider should return message list")

        // Subscribe to lists and check contents
        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)
        messageList.observe(with: self) { list in
            messagesReceived.fulfill()
            XCTAssertEqual(list?.count, generatedMessageList.count)
        }

        waitForExpectations(timeout: 1, handler: nil)

        messageList.removeObserver(self)
    }

    func testDeleteMessage() {
        // Generate test data
        let generatedMessageList = MessageItemGenerator.createDiverseMessageList(conversationSid: mockedConversationSid)

        guard let deleteMessageSid = generatedMessageList.first?.sid else {
            XCTFail()
            return
        }

        let deleteList: [String] = [deleteMessageSid]

        // Insert values into cache
        messagesDAO.upsertMessages(generatedMessageList)
        messagesDAO.deleteMessages(by: deleteList)

        let messagesReceived = expectation(description: "LocalCacheProvider should return empty message list")

        // Subscribe to lists and check contents
        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)
        messageList.observe(with: self) { list in
            messagesReceived.fulfill()
            XCTAssertEqual(list?.count, generatedMessageList.count - 1)
            XCTAssertFalse(list?.contains { $0.sid == deleteMessageSid} ?? true, "Message should no longer be in the list")
        }

        waitForExpectations(timeout: 1, handler: nil)

        messageList.removeObserver(self)
    }


    func testReactionsToMessageArePersisted() {
        // Generate test data
        let message = MessageDataItem(
            sid: "message-a",
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .text,
            reactions: MessageReactionsModel()
        )
        message.reactions.tooggleReaction(.heart, forParticipant: "participant-a")
        messagesDAO.upsertMessages([message])

        let retrieved = messagesDAO.getMessageWithSid("message-a")
        XCTAssertEqual(retrieved?.reactions?.count, 1)
        let reaction = retrieved!.reactions!.first!
        XCTAssertEqual(reaction.reactionType, "❤️")
        XCTAssertEqual(reaction.participant?.identity, "participant-a")

        // Check the PersistentMessage is converted back to
        let dataItem = retrieved?.getMessageDataItem()
        XCTAssertEqual(dataItem?.reactions.reactionDict, [ReactionType.heart: Set(["participant-a"])])
    }

    func testReactingOnMessageTriggerAnObserverUpdate() {
        // Generate test data
        let message = MessageDataItem(
            sid: "message-a",
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .text,
            reactions: MessageReactionsModel()
        )
        messagesDAO.upsertMessages([message])

        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)
        let messageUpdatesReceived = XCTestExpectation(description: "we should receive a message update after the reaction are added to the message")
        message.reactions.tooggleReaction(.heart, forParticipant: "participant-a")
        messagesDAO.upsertMessages([message])

        messageList.observe(with: self) { list in
            messageUpdatesReceived.fulfill()
            XCTAssertEqual(1, list?.first?.reactions?.count)
        }
        wait(for: [messageUpdatesReceived], timeout: 1)
        messageList.removeObserver(self)
    }

    func testMutlipleReactingOnMessageTriggerAnObserverUpdate() {
        // Generate test data
        let message = MessageDataItem(
            sid: "message-a",
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .text,
            reactions: MessageReactionsModel()
        )
        messagesDAO.upsertMessages([message])

        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)
        let messageUpdatesReceived = XCTestExpectation(description: "we should receive a message update after the reaction are added to the message")
        message.reactions.tooggleReaction(.heart, forParticipant: "participant-a")
        messagesDAO.upsertMessages([message])

        message.reactions.tooggleReaction(.sad, forParticipant: "participant-a")
        messagesDAO.upsertMessages([message])

        messageList.observe(with: self) { list in
            messageUpdatesReceived.fulfill()
            XCTAssertEqual(2, list?.first?.reactions?.count)
        }
        wait(for: [messageUpdatesReceived], timeout: 1)
        messageList.removeObserver(self)
    }


    func testUntoggleReaction() {
        // Generate test data
        let message = MessageDataItem(
            sid: "message-a",
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .text,
            reactions: MessageReactionsModel()
        )
        messagesDAO.upsertMessages([message])

        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)
        let messageUpdatesReceived = XCTestExpectation(description: "we should receive a message update after the reaction are added to the message")
        message.reactions.tooggleReaction(.heart, forParticipant: "participant-a")
        messagesDAO.upsertMessages([message])

        message.reactions.tooggleReaction(.sad, forParticipant: "participant-a")
        messagesDAO.upsertMessages([message])

        message.reactions.tooggleReaction(.sad, forParticipant: "participant-a")
        messagesDAO.upsertMessages([message])

        messageList.observe(with: self) { list in
            messageUpdatesReceived.fulfill()
            XCTAssertEqual(1, list?.first?.reactions?.count)
        }
        wait(for: [messageUpdatesReceived], timeout: 1)
        messageList.removeObserver(self)
    }

    func testMediaPropertiesSupport() {
        let mediaProperties =  MediaMessageProperties(mediaURL: URL(string: "http://someimagelocation.jpg")!, messageSize:25, uploadedSize: 0)

        let message = MessageDataItem(
            sid: "message-a",
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .text,
            reactions: MessageReactionsModel(),
            mediaProperties: mediaProperties
        )
        let messageUpdatesReceived = XCTestExpectation(description: "we should receive a message update after the reaction are added to the message")
        messagesDAO.upsertMessages([message])
        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)

        messageList.observe(with: self) { list in
            messageUpdatesReceived.fulfill()
            guard let messageItem = list?.first?.getMessageDataItem() else {
                return XCTFail("Could not convert the the Peristent to a message data item")
            }
            XCTAssertEqual(messageItem.mediaProperties, mediaProperties)
        }
    }


    func testMediaPropertiesUpdateAfterInsert() {


        let message = MessageDataItem(
            sid: "message-a",
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .media,
            reactions: MessageReactionsModel()
        )

        let observerFiredFullfilement  = XCTestExpectation(description: "We should notify the observer after the message is insterted")
        observerFiredFullfilement.expectedFulfillmentCount = 2

        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid)
        messagesDAO.upsertMessages([message])

        var fullfilled = 0
        messageList.observe(with: self) { list in
            XCTAssertEqual(list?.count, 1, "The list size should be 1")
            guard let messageItem = list?.first?.getMessageDataItem() else {
                return XCTFail("Could not convert the the Peristent to a message data item")
            }
            if fullfilled == 1  {
                XCTAssertEqual(messageItem.mediaProperties?.mediaURL?.absoluteString, "https://testurl.com")
            }
            observerFiredFullfilement.fulfill()
            fullfilled += 1
        }
        message.mediaProperties = MediaMessageProperties(mediaURL: URL(string: "https://testurl.com")!, messageSize: 0, uploadedSize: 0)
        messagesDAO.upsertMessages([message])
    }

    func testGetListOfParticipantForReactionTypeOnMessage() {
        // Create conversation
        let messageSid = "message-a"
        // Generate test data
        let message = MessageDataItem(
            sid: messageSid,
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .text,
            reactions: MessageReactionsModel()
        )
        // Add message
        messagesDAO.upsertMessages([message])
        // Create participants
        createParticipants(onConversation: mockedConversationSid)
        // Create a few thumb up from several participant on message
        message.reactions.tooggleReaction(.thumbsUp, forParticipant: "participant-a")
        message.reactions.tooggleReaction(.thumbsUp, forParticipant: "participant-b")
        message.reactions.tooggleReaction(.thumbsUp, forParticipant: "participant-c")
        messagesDAO.upsertMessages([message])
        // Check that we have 3 reactions
        XCTAssertEqual(messagesDAO.getMessageWithSid(messageSid)?.reactions?.count, 3)
        
        // Get the list of participants who reacted to the message
        let observableParticipants = reactionDAO.getReactions(onMessage: messageSid, withType: .thumbsUp)
        XCTAssertEqual(observableParticipants.value?.count, 3)

        // Untoggle a reaction
        message.reactions.tooggleReaction(.thumbsUp, forParticipant: "participant-c")
        messagesDAO.upsertMessages([message])

        let secondRequestObserver = reactionDAO.getReactions(onMessage: messageSid, withType: .thumbsUp)
        XCTAssertEqual(secondRequestObserver.value?.count, 2)

    }


    func tesDeleteMessageWithReactions() {
        // Create conversation
        let messageSid = "message-a"
        // Generate test data
        let message = MessageDataItem(
            sid: messageSid,
            uuid: "uuid1",
            index: 0,
            direction: .incoming,
            author: "kevin",
            body: "I am testing reaction persistence",
            dateCreated: 1,
            sendStatus: .sent,
            conversationSid: mockedConversationSid,
            type: .text,
            reactions: MessageReactionsModel()
        )
        // Add message
        messagesDAO.upsertMessages([message])
        // Create participants
        createParticipants(onConversation: mockedConversationSid)
        // Create a few thumb up from several participant on message
        message.reactions.tooggleReaction(.thumbsUp, forParticipant: "participant-a")
        message.reactions.tooggleReaction(.thumbsUp, forParticipant: "participant-b")
        message.reactions.tooggleReaction(.thumbsUp, forParticipant: "participant-c")
        messagesDAO.upsertMessages([message])
        messagesDAO.deleteMessages(by: [messageSid])
        let messageList = messagesDAO.getObservableConversationMessages(by: mockedConversationSid).value
        XCTAssertEqual(0, messageList?.count)
    }


    private func createParticipants(onConversation conversation: String)  {
        let participantA = ParticipantDataItem(sid: "sid-a", conversationSid: conversation, identity: "participant-a", type: Int16(0), attributes: nil)
        let participantB = ParticipantDataItem(sid: "sid-b", conversationSid: conversation, identity: "participant-b", type: Int16(0), attributes: nil)
        let participantC = ParticipantDataItem(sid: "sid-c", conversationSid: conversation, identity: "participant-c", type: Int16(0), attributes: nil)
        participantDAO.upsertParticipants([participantA, participantB, participantC])
    }
}
