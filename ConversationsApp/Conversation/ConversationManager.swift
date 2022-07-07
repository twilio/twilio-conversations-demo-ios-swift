//
//  ConversationsManager.swift
//  ConversationsApp
//
//  Created by Cece Laitano on 4/4/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient
import CoreData
import Combine

enum ConversationEvent {
    case leftConversation
    case messageCopied
    case messageDeleted
    case notificationsTurnedOn
    case notificationsTurnedOff
    case participantAdded
    case participantRemoved
}

class ConversationManager: ObservableObject {
    
    @Published var conversations = [PersistentConversationDataItem]()
    @Published var isConversationsLoading = false
    @Published var isConversationsRefreshing = false
    
    private var client: ConversationsClientWrapper = ConversationsClientWrapper()
    private var cancellableSet: Set<AnyCancellable> = []
    private var coreDataDelegate: CoreDataDelegate
    
    // MARK: Events
    
    var conversationEventPublisher = PassthroughSubject<ConversationEvent, Never>()
    
    init(_ client: ConversationsClientWrapper, coreDataDelegate: CoreDataDelegate ) {
        self.client = client
        self.coreDataDelegate = coreDataDelegate
    }
    

    func subscribeConversations(onRefresh: Bool) {
        if (onRefresh) {
            isConversationsRefreshing = true
        } else {
            isConversationsLoading = true
        }
        NSLog("Setting up Core Data update subscription for Conversations")
        
        let request = PersistentConversationDataItem.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "lastMessageDate", ascending: false),
            NSSortDescriptor(key: "friendlyName", ascending: true)]
        
        ObservableResultPublisher(with: request, context: coreDataDelegate.managedObjectContext)
            .sink(
                receiveCompletion: {
                    NSLog("Completion from fetch conversations - \($0)")
                },
                receiveValue: { [weak self] items in
                    let sortedItems = items.sorted(by: self!.sorterForConversations)
                    self?.conversations = sortedItems
                    
                    if (onRefresh) {
                        self?.isConversationsRefreshing = false
                    } else {
                        self?.isConversationsLoading = false
                    }
                })
            .store(in: &cancellableSet)
    }
    
    func sorterForConversations(this:PersistentConversationDataItem, that:PersistentConversationDataItem) -> Bool {
        // Some conversations have null values so excluding from sorting
        if (this.dateCreated == nil){
            return false
        }
        if (that.dateCreated == nil){
            return true
        }
        
        let thisDate = this.lastMessageDate == nil ? this.dateCreated : this.lastMessageDate
        let thatDate = that.lastMessageDate == nil ? that.dateCreated : that.lastMessageDate
        
        return thisDate! > thatDate!
    }

    func loadAllConversations() {
        guard let client = client.conversationsClient else {
            return
        }

        let _ = client.myConversations()?.map({ PersistentConversationDataItem.from(conversation: $0, inContext: coreDataDelegate.managedObjectContext)})
        coreDataDelegate.saveContext()
    }

    func retrieveConversation(_ conversationSid: String, completion: @escaping (TCHConversation?, Error?) -> Void) {
        guard let client = client.conversationsClient else {
            completion(nil, DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.conversation(withSidOrUniqueName: conversationSid) { (result, conversation) in
            guard result.isSuccessful, let conversation = conversation else {
                completion(nil, DataFetchError.requiredDataCallsFailed)
                return
            }
            completion(conversation, nil)
        }
    }

    func createAndJoinConversation(friendlyName: String?, completion: @escaping (Error?) -> Void) {
        let creationOptions: [String: Any] = [
            TCHConversationOptionFriendlyName: friendlyName ?? "",
        ]
        
        guard let client = client.conversationsClient else {
            completion(DataFetchError.conversationsClientIsNotAvailable)
            return
        }

        client.createConversation(options: creationOptions) { result, conversation in
            guard let conversation = conversation else {
                completion(result.error)
                return
            }
            
            conversation.join { result in
                completion(result.error)
            }
        }
    }

    func toggleMute(onConversation item: PersistentConversationDataItem) {
        if let conversationSid = item.sid {
            retrieveConversation(conversationSid) { (conversation, error) in
                self.coreDataDelegate.managedObjectContext.perform {
                    let isConversationMuted = item.muted
                    conversation?.setNotificationLevel(isConversationMuted ? .default : .muted) { result in
                        NSLog("\(result)")
                        if (result.isSuccessful) {
                            self.conversationEventPublisher.send(isConversationMuted ? .notificationsTurnedOff : .notificationsTurnedOn)
                        }
                    }
                }
            }
        }
    }
    
    func renameConversation(sid: String, name: String?, completion: @escaping (Error?) -> Void) {
        retrieveConversation(sid) { (conversation, error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.setFriendlyName(name) { result in
                completion(result.error)
            }
        }
    }
    
    func leave(conversation item: PersistentConversationDataItem) {
        if let conversationSid = item.sid {
            retrieveConversation(conversationSid) { (tchConversation, error) in
                tchConversation?.leave() { result in
                    NSLog("\(result)")
                }
                self.conversationEventPublisher.send(.leftConversation)
            }
        }
    }
}
