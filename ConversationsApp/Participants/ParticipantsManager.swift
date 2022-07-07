//
//  ParticipantsManager.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-04-26.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient
import Combine

class ParticipantsManager: ObservableObject {
    
    @Published var participants = [PersistentParticipantDataItem]()
    
    private var coreDataDelegate: CoreDataDelegate
    private var conversationManager: ConversationManager
    private var cancellableSet: Set<AnyCancellable> = []
    
    init(coreDataDelegate: CoreDataDelegate, conversationManager: ConversationManager) {
        self.coreDataDelegate = coreDataDelegate
        self.conversationManager = conversationManager
    }
    
    func subscribeParticipants(inConversation conversation: PersistentConversationDataItem) {
        AppModel.shared.selectedConversation = conversation
        NSLog("Setting up Core Data update subscription for Participants of conversation \(conversation.sid ?? "<unknown>")")
        
        if let conversationSid = conversation.sid {
            let request = PersistentParticipantDataItem.fetchRequest()
            request.predicate = NSPredicate(format: "conversationSid = %@", conversationSid)
            request.sortDescriptors = [NSSortDescriptor(key: "sid", ascending: true)]

            ObservableResultPublisher(with: request, context: coreDataDelegate.managedObjectContext)
            .sink(
                receiveCompletion: {
                    NSLog("Completion from fetch participants - \($0)")
                },
                receiveValue: { [weak self] items in
                    self?.participants = items
                })
            .store(in: &cancellableSet)
        }
    }
    
    func addNonChatParticipant(_ phoneNumber: String, proxyNumber: String, participantType: AddParticipantFlow, conversation: String, completion: @escaping(Error?) -> Void) {
        conversationManager.retrieveConversation(conversation) { (conversation, error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }
            
            let phoneNumber = participantType == .whatsapp ? "whatsapp:+\(phoneNumber)" : "+\(phoneNumber)"
            let proxyNumber = participantType == .whatsapp ? "whatsapp:+\(proxyNumber)" : "+\(proxyNumber)"
            
            print("Adding \(phoneNumber) via \(proxyNumber)")
            
            let attributes = [
                "friendlyName": phoneNumber
            ]
            
            let jsonAttributes = TCHJsonAttributes.init(dictionary: attributes)

            conversation.addParticipant(byAddress: phoneNumber, proxyAddress: proxyNumber, attributes: jsonAttributes) { (result) in
                if (result.error != nil) {
                    print("Error whilst adding \(phoneNumber): \(String(describing: result.error))")
                } else {
                    print("Added \(phoneNumber) to conversation successfully")
                    self.conversationManager.conversationEventPublisher.send(.participantAdded)
                }
                
                completion(result.error) // nil means success
            }
        }
    }
    
    func addChatParticipant(_ identity: String, conversation: String, completion: @escaping (Error?) -> Void) {
        conversationManager.retrieveConversation(conversation) { (conversation, error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let conversation = conversation else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }

            conversation.addParticipant(byIdentity: identity, attributes: nil) { (result) in
                if (result.error == nil) {
                    self.conversationManager.conversationEventPublisher.send(.participantAdded)
                }
                
                completion(result.error) // nil means success
            }
        }
    }
    
    func removeParticipant(participantSid: String, conversationSid: String, completion: @escaping (Error?) -> Void) {
        conversationManager.retrieveConversation(conversationSid) { (conversation, error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let conversation = conversation,
                  let participant = conversation.participants().first(where: { $0.sid == participantSid })
            else {
                completion(DataFetchError.requiredDataCallsFailed)
                return
            }
            
            conversation.removeParticipant(participant) { result in
                if result.error == nil {
                    self.conversationManager.conversationEventPublisher.send(.participantRemoved)
                }
                
                completion(result.error)
            }
        }
    }
}
