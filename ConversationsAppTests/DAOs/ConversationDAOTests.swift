//
//  ConversationDAOTests.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import XCTest
import TwilioConversationsClient

@testable import ConversationsApp

fileprivate class ConversationDAOTest: XCTestCase {

    private let conversationDAO = ConversationDAOImpl()

    var userConversationListObservable: ObservableFetchRequestResult<PersistentConversationDataItem>!

    override func setUp() {
        conversationDAO.clearConversationList()
        userConversationListObservable = conversationDAO.getObservableConversationList()
    }

    override func tearDown() {
        userConversationListObservable?.removeObserver(self)
        conversationDAO.clearConversationList()
    }

    func testDeleteConversations() {
        // Insert values into cache
        let list = ConversationItemGenerator.createDiverseConversationList()
        conversationDAO.insertOrUpdate(list)

        let deleteList: [String] = list.map { $0.sid }
        conversationDAO.delete(deleteList)

        let userConversationListReceived = expectation(description: "LocalCacheProvider should return user conversation list values")

        // Subscribe to lists and check contents
        userConversationListObservable?.observe(with: self) { list in
            XCTAssertEqual(list?.count, 0)
            userConversationListReceived.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testInsertConversation() {
        // Insert values into cache
        let list = ConversationItemGenerator.createDiverseConversationList()
        conversationDAO.insertOrUpdate(list)

        let userConversationListReceived = expectation(description: "LocalCacheProvider should return user conversation list values")

        // Subscribe to lists and check contents
        userConversationListObservable?.observe(with: self) { list in
            XCTAssertEqual(list?.count, 6)
            userConversationListReceived.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateConversationWithEmptyCache() {
        // Try to insert values into cache with update
        let list = ConversationItemGenerator.createDiverseConversationList()
        conversationDAO.insertOrUpdate(list)

        let userConversationListReceived = expectation(description: "LocalCacheProvider should return user conversation list values")

        // Subscribe to lists and check contents
        userConversationListObservable?.observe(with: self) { list in
            XCTAssertEqual(list?.count, 6)
            userConversationListReceived.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateConversation() {
        // Insert values into cache
        var list = ConversationItemGenerator.createDiverseConversationList()
        conversationDAO.insertOrUpdate(list)

        // Update all item friendly names
        let newFriendlyName = "UPDATED"
        list.mutateEach{ $0.friendlyName = newFriendlyName }

        conversationDAO.insertOrUpdate(list)

        let userConversationListReceived = expectation(description: "LocalCacheProvider should return user conversation list values")

        // Subscribe to lists and check contents
        userConversationListObservable?.observe(with: self) { list in
            guard let list = list else {
                XCTFail("Returned nil value")
                return
            }
            list.forEach {
                XCTAssertEqual($0.friendlyName, newFriendlyName, "Conversation item should be updated")
            }
            userConversationListReceived.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testConversationObservers() {
        // Initial list should be empty and once we delete it and also when we clear it
        let expectEmptyUserConversationList = expectation(description: "LocalCacheProvider should return empty user conversation list")
        expectEmptyUserConversationList.expectedFulfillmentCount = 2

        // After insert and update list should be populated
        let expectUserConversationListPopulated = expectation(description: "LocalCacheProvider should return user conversation list")
        expectUserConversationListPopulated.expectedFulfillmentCount = 2

        // Observe lists
        userConversationListObservable?.observe(with: self) { list in
            switch list?.count {
            case 0: expectEmptyUserConversationList.fulfill()
            case 6: expectUserConversationListPopulated.fulfill()
            default:
                XCTFail("Something is not correct, \(list?.count ?? -1)")
            }
        }

        // Insert and then clear values, observers should be notified
        let list = ConversationItemGenerator.createDiverseConversationList()

        // Calling insert which should notify observer
        conversationDAO.insertOrUpdate(list)

        // Calling update which should notify observer
        conversationDAO.insertOrUpdate(list)

        // Calling clear which should notify observer
        conversationDAO.clearConversationList()

        waitForExpectations(timeout: 100, handler: nil)
    }
}
