//
//  MessagesManager.swift
//  ConversationsApp
//
//  Created by Cece Laitano on 4/6/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient
import Combine

class MessagesManager: ObservableObject {
    
    @Published var messages = [PersistentMessageDataItem]()
    
    private var coreDataDelegate: CoreDataDelegate
    private var conversationManager: ConversationManager
    private var cancellableSet: Set<AnyCancellable> = []
    
    init(coreDataDelegate: CoreDataDelegate, conversationManager: ConversationManager ) {
        self.coreDataDelegate = coreDataDelegate
        self.conversationManager = conversationManager
    }
    
    func subscribeMessages(inConversation conversation: PersistentConversationDataItem) {
        AppModel.shared.selectedConversation = conversation
        NSLog("Setting up Core Data update subscription for Messages in conversation \(conversation.sid ?? "<unknown>")")
        
        if let conversationSid = conversation.sid {
            let request = PersistentMessageDataItem.fetchRequest()
            request.predicate = NSPredicate(format: "conversationSid = %@", conversationSid)
            request.sortDescriptors = [NSSortDescriptor(key: "messageIndex", ascending: true)]
            
            ObservableResultPublisher(with: request, context: coreDataDelegate.managedObjectContext)
                .sink(
                    receiveCompletion: {
                        NSLog("Completion from fetch messages - \($0)")
                    },
                    receiveValue: { [weak self] items in
                        self?.messages = items
                    })
                .store(in: &cancellableSet)
        }
    }
    
    func loadLastMessagePageIn(_ conversationItem: PersistentConversationDataItem, max: UInt) {
        guard let sid = conversationItem.sid else {
            return
        }
        
        conversationManager.retrieveConversation(sid) { (conversation, error) in
            conversation?.getLastMessages(withCount: max) { (result, messages) in
                if let _ = messages?.map({ PersistentMessageDataItem.from(message: $0, inConversation: conversation!, withDirection: $0.author == AppModel.shared.myIdentity ? .outgoing : .incoming, inContext: self.coreDataDelegate.managedObjectContext) }) {
                    self.coreDataDelegate.saveContext()
                }
            }
        }
    }
    
    func loadMessages(for conversationItem: PersistentConversationDataItem, before messageIndex: Int64, max: UInt) {
        guard let sid = conversationItem.sid else {
            return
        }
        conversationManager.retrieveConversation(sid) { (conversation, error) in
            // getMessagesBefore fetches at most count messages including and prior to the specified index. Therefore we need
            // to ask for 1 more than max, to get the exact max that we want.
            conversation?.getMessagesBefore(UInt(messageIndex), withCount: max + 1, completion: { (result, messages) in
                if let _ = messages?.map({ PersistentMessageDataItem.from(message: $0, inConversation: conversation!, withDirection: $0.author == AppModel.shared.myIdentity ? .outgoing : .incoming, inContext: self.coreDataDelegate.managedObjectContext) }) {
                    self.coreDataDelegate.saveContext()
                }
            })
        }
    }
    
    func updateMessage(attributes: [String: Any]?, for messageIndex: Int64?, conversationSid: String?) {
        guard let conversationSid = conversationSid,
              let attributes = attributes,
              let messageIndex = messageIndex else {
            return
        }
        conversationManager.retrieveConversation(conversationSid) { tchConversation, error in
            tchConversation?.message(withIndex:  NSNumber(integerLiteral: Int(messageIndex)), completion: { result, tchMessage in
                guard let messageToUpdate = tchMessage,
                      let jsonAttributes = TCHJsonAttributes(dictionary: attributes) else {
                    return
                }
                messageToUpdate.setAttributes(jsonAttributes) { result in
                    if result.error != nil {
                        print("Updating message attributes returned an error: \(String(describing: result.error)) - error code: \(result.resultCode)")
                    } else {
                        print("Message attributes updated successfully!")
                    }
                }
            })
        }
    }
    
    private func retrieveMessageIn(_ conversation: TCHConversation, messageIndex: NSNumber, completion: @escaping (TCHMessage?, Error?) -> Void) {
        conversation.message(withIndex: messageIndex) { (result, message) in
            guard result.isSuccessful, let message = message else {
                completion(nil, DataFetchError.requiredDataCallsFailed)
                return
            }
            
            completion(message, nil)
        }
    }
    
    func copyMessage() {
        conversationManager.conversationEventPublisher.send(.messageCopied)
    }
    
    func deleteMessage(_ message: PersistentMessageDataItem) {
        guard let conversationSid = message.conversationSid else {
            return
        }
        
        let messageIndex = NSNumber(value: message.messageIndex)
        
        conversationManager.retrieveConversation(conversationSid) { [self] (conversation, error) in
            guard let conversation = conversation, error == nil else {
                return
            }
            
            self.retrieveMessageIn(conversation, messageIndex: messageIndex) { (message, error) in
                guard let message = message, error == nil else {
                    return
                }
                
                conversation.remove(message) { (result) in
                    guard result.isSuccessful else {
                        return
                    }
                    
                    self.conversationManager.conversationEventPublisher.send(.messageDeleted)
                }
            }
        }
    }
    
    func sendMessage(toConversation conversationItem: PersistentConversationDataItem, withText text: String?, andMedia url: NSURL?, withFileName filename: String?, completion: @escaping (TCHError?) -> ()) {
        guard let sid = conversationItem.sid else {
            return
        }
        
        conversationManager.retrieveConversation(sid) { (conversation, error) in
            if url != nil {
                conversation?.prepareMessage()
                    .addMedia(inputStream: InputStream(url: (url as URL?)!)!, contentType: "image/jpeg", filename: filename, listener: .init(onStarted: {
                        // Called when upload of media begins.
                        print("[MediaMessage] Media upload started")
                    }, onProgress: { bytesSent in
                        print("Current progress \(bytesSent)")
                        _ = MediaMessageProperties(mediaURL: nil,
                                                   messageSize: -1,
                                                   uploadedSize: Int(bytesSent))
                    }, onCompleted: { mediaSid in
                        print("[MediaMessage] Upload completed for sid \(mediaSid)")
                        completion(nil)
                    }, onFailed: { error in
                        print("Media upload failed with error \(error)")
                    }))
                    .buildAndSend { result, message in
                        if let error = result.error {
                            NSLog("Error encountered while sending message: \(error)")
                        }
                        
                        completion(result.error)
                    }
            } else {
                guard let text = text, text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
                    return
                }
                
                conversation?.prepareMessage()
                    .setBody(text)
                    .buildAndSend { result, message in
                        if let error = result.error {
                            NSLog("Error encountered while sending message: \(error)")
                        }
                        
                        completion(result.error)
                    }
            }
        }
    }

    func setAllMessagesRead(for conversationSid: String?) {
        guard let conversationSid = conversationSid else {
            return
        }
        conversationManager.retrieveConversation(conversationSid) { (conversation, error) in
            guard let conversation = conversation, error == nil else {
                return
            }
            conversation.setAllMessagesReadWithCompletion { result, updatedUnreadMessageCount  in
                if result.isSuccessful {
                    NSLog("All messages set as read for conversation \(conversationSid)")
                } else {
                    NSLog("Error - not able to set all messages as read for conversation \(conversationSid)")
                }
            }
        }
    }
    
}
