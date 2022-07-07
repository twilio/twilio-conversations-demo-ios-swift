//
//  AppModel.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 17.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import Combine
import CoreData
import Network
import SwiftUI
import TwilioConversationsClient

///
/// AppModel is a repository of application's globally available data and operations.
/// See https://github.com/shufflingB/swiftui-core-data-with-model/ for details about AppModel.
///
///

class AppModel: NSObject, ObservableObject {
    static let shared = AppModel() // used only for AppDelegate to notify the client of Push Notification device token changes
    
    // CoreData objects are directly exposed and are then mapped into ViewModels for particular view as needed.
    @Published var selectedConversation: PersistentConversationDataItem? = nil
    @Published var myIdentity = ""
    @Published var myUser: TCHUser?
    @Published var globalStatus: GlobalStatus = .none
    @Published var conversationsError: TCHError? = nil
    
    private var clientState: TCHClientConnectionState = .unknown
    private var imageCache = DefaultImageCache.shared
    private(set) var client: ConversationsClientWrapper = ConversationsClientWrapper()
    private let networkMonitor = NWPathMonitor()
    var deviceToken: Data?
    
    var coreDataManager: CoreDataManager!
    var conversationManager: ConversationManager!
    var messagesManager: MessagesManager!
    var participantsManager: ParticipantsManager!

    // MARK: Global Status
    
    enum GlobalStatus {
        case none
        case noConnectivity
        case signedOutSuccessfully
    }
    
    // MARK: Typing

    enum TypingActivity {
        case startedTyping(Conversation, Participant)
        case stoppedTyping(Conversation, Participant)
    }

    public var typingPublisher = PassthroughSubject<TypingActivity, Never>()

    private var cancellableSet: Set<AnyCancellable> = []

    init(inMemory: Bool = false) {
        coreDataManager = CoreDataManager(inMemory: inMemory)
        
        super.init()
        
        conversationManager = ConversationManager(client, coreDataDelegate: coreDataManager)
        conversationManager.subscribeConversations(onRefresh: false)
        messagesManager = MessagesManager(coreDataDelegate: coreDataManager, conversationManager: conversationManager)
        participantsManager = ParticipantsManager(coreDataDelegate: coreDataManager, conversationManager: conversationManager)
        
        // subscribe to changes regarding the user's network connectivity
        
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.globalStatus = .none
            } else {
                self.globalStatus = .noConnectivity
            }
        }
        
        networkMonitor.start(queue: .main)
    }
    
    func getManagedContext() -> NSManagedObjectContext {
        return coreDataManager.managedObjectContext
    }

    // MARK: Client

    func saveUser(_ user: TCHUser?) {
        self.myUser = user
        self.myIdentity = user!.identity!
    }

    func signOut() {
        deregisterFromPushNotifications()
        
        try? ConversationsCredentialStorage.shared.deleteCredentials()

        DispatchQueue.main.async {
            self.globalStatus = .signedOutSuccessfully
            DispatchQueue.main.asyncAfter(deadline: .now() + GlobalStatusView.ttl) {
                self.clientState = .unknown
                self.globalStatus = .none
            }
            self.client.shutdown()
        }
        
        self.wipeAllCache()
    }
    
    func registerForPushNotifications() {
        guard let token = self.deviceToken else {
            return
        }
        
        client.registerForPushNotifications(token)
    }
    
    func deregisterFromPushNotifications() {
        guard let token = self.deviceToken else {
            return
        }
        
        client.deregisterFromPushNotifications(token)
    }
    
    func wipeAllCache() {
        let managedObjectContext = getManagedContext()
        PersistentConversationDataItem.deleteAllUnchecked(inContext: managedObjectContext)
        PersistentMessageDataItem.deleteAllUnchecked(inContext: managedObjectContext)
        PersistentParticipantDataItem.deleteAllUnchecked(inContext: managedObjectContext)
    }
    
    // MARK: Media
    
    func getMediaAttachmentURL(for messageIndex: Int64?, conversationSid: String?, completion: @escaping (URL?) -> ()) {
        guard let conversationSid = conversationSid,
              let messageIndex = messageIndex else {
                  return
              }
        conversationManager.retrieveConversation(conversationSid) { tchConversation, error in
            tchConversation?.message(withIndex:  NSNumber(integerLiteral: Int(messageIndex)), completion: { result, tchMessage in
                guard let message = tchMessage else {
                    return
                }
                //For Demo Apps v1 we're going to assume that first media attachment is the only one.
                guard let media = message.attachedMedia.first else { return }
                
                if self.imageCache.hasDataFor(sid: media.sid) {
                    print("[Media] No need to download the message with index \(messageIndex)")
                    DispatchQueue.main.async {
                        completion(self.imageCache.urlFor(sid: media.sid))
                    }
                    return
                }
                
                print("[Media] Must download the image \(media.sid) to cache")
                
                media.getTemporaryContentUrl { [weak self] result, url in
                    guard result.error == nil, let url = url else {
                        print("[Media] Getting media attachment url returned an error \(String(describing: result.error))")
                        return
                    }
                    
                    self?.imageCache.copyToAppCache(forSid: media.sid, from: url) { cachedResult in
                        switch cachedResult {
                        case .success(let image):
                            print("[Media][cache] Download succes for message with Index: \(messageIndex)")
                            DispatchQueue.main.async {
                                completion(image.url)
                            }
                        case .failure(let error):
                            print("[Media][cache] Download error for message with Index: \(messageIndex) - \(error)")
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
                    }
                }
            })
        }
    }

    // MARK: Local Typing

    func typing(in item: PersistentConversationDataItem?) {
        guard let convo = item, let conversationSid = convo.sid else {
            return
        }
        conversationManager.retrieveConversation(conversationSid) { (conversation, error) in
            conversation?.typing()
        }
    }
}

// MARK: Client delegate methods
extension AppModel: TwilioConversationsClientDelegate {

    // MARK: Client changes
    
    func conversationsClient(_ client: TwilioConversationsClient, connectionStateUpdated state: TCHClientConnectionState) {
        self.clientState = state
    }
    
    func conversationsClientTokenWillExpire(_ client: TwilioConversationsClient) {
        self.client.conversationsClientTokenWillExpire(client)
    }
    
    func conversationsClientTokenExpired(_ client: TwilioConversationsClient) {
        self.client.conversationsClientTokenExpired(client)
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversationsError errorReceived: TCHError) {
        DispatchQueue.main.async {
            self.conversationsError = errorReceived
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        if status == .failed {}
        if status == .completed {
            conversationManager.loadAllConversations()
        }
    }

    // MARK: Conversation changes

    func conversationsClient(_ client: TwilioConversationsClient, conversationAdded conversation: TCHConversation) {
        NSLog("Conversation added: \(String(describing: conversation.sid)) w/ name \(String(describing: conversation.friendlyName))")
        conversation.delegate = self
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: getManagedContext()) {
            coreDataManager.saveContext()
            NSLog("Conversation upserted")
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversationDeleted conversation: TCHConversation) {
        if let conversationSid = conversation.sid {
            PersistentConversationDataItem.deleteConversationsUnchecked([conversationSid], inContext: getManagedContext())
            PersistentMessageDataItem.deleteAllMessagesByConversationSid([conversationSid], inContext: getManagedContext())
            PersistentParticipantDataItem.deleteAllParticipantsByConversationSid([conversationSid], inContext: getManagedContext())
            PersistentMediaDataItem.deleteAllMediaItemsByConversationSid([conversationSid], inContext: getManagedContext())
        }
    }

    // MARK: Typing changes

    func conversationsClient(_ client: TwilioConversationsClient, typingStartedOn conversation: TCHConversation, participant: TCHParticipant) {
        let conversation = TCHAdapter.transform(from: conversation)
        let participant =  TCHAdapter.transform(from: participant)
        typingPublisher.send(.startedTyping(conversation, participant))
    }

    func conversationsClient(_ client: TwilioConversationsClient, typingEndedOn conversation: TCHConversation, participant: TCHParticipant) {
        let conversation = TCHAdapter.transform(from: conversation)
        let participant =  TCHAdapter.transform(from: participant)
        typingPublisher.send(.stoppedTyping(conversation, participant))
    }
    
    // MARK: User changes

    func conversationsClient(_ client: TwilioConversationsClient, user: TCHUser, updated update: TCHUserUpdate) {
        if user.identity == myIdentity {
            myUser = user
        }
    }
}

// MARK: TCHConversationDelegate methods

extension AppModel: TCHConversationDelegate {

    // MARK: Conversation changes

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, updated update: TCHConversationUpdate) {
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: getManagedContext()) {
            coreDataManager.saveContext()
        }
    }

    // MARK: Message changes

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, message: TCHMessage, updated: TCHMessageUpdate) {
        let managedObjectContext = getManagedContext()
        if let _ = PersistentMessageDataItem.from(message: message, inConversation: conversation, withDirection: message.author == self.myIdentity ? .outgoing : .incoming, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        guard conversation.sid != nil else {
            return
        }
                        
        let managedObjectContext = getManagedContext()

        if let _ = PersistentMessageDataItem.from(message: message, inConversation: conversation, withDirection: message.author == myIdentity ? .outgoing : .incoming, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }

        // Update conversation last message stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageDeleted message: TCHMessage) {
        guard let messageSid = message.sid else {
            return
        }
        
        let managedObjectContext = getManagedContext()
        PersistentMessageDataItem.deleteMessagesUnchecked([messageSid], inContext: managedObjectContext)

        // Update conversation last message stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }
    }

    // MARK: Client changes

    func conversationsClient(_ client: TwilioConversationsClient,
                             conversation: TCHConversation,
                             synchronizationStatusUpdated status: TCHConversationSynchronizationStatus) {
        guard conversation.synchronizationStatus.rawValue >= TCHConversationSynchronizationStatus.all.rawValue else {
            return
        }

        // Update conversation last message stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: getManagedContext()) {
            coreDataManager.saveContext()
        }
    }

    // MARK: Participant changes

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantJoined participant: TCHParticipant) {
        let managedObjectContext = getManagedContext()
        
        if let _ = PersistentParticipantDataItem.from(participant: participant, inConversation: conversation, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }

        // Update conversation participant stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participant: TCHParticipant, updated: TCHParticipantUpdate) {
        let managedObjectContext = getManagedContext()
        
        if let _ = PersistentParticipantDataItem.from(participant: participant, inConversation: conversation, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }
        
        // Update conversation participant stats
        if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: managedObjectContext) {
            coreDataManager.saveContext()
        }
    }

    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, participantLeft participant: TCHParticipant) {
        guard let conversationSid = conversation.sid,
              let participantSid = participant.sid else {
                  return
              }
        
        let managedObjectContext = getManagedContext()
        PersistentParticipantDataItem.deleteParticipants([participantSid], inContext: managedObjectContext)
        
        if participant.identity == myIdentity {
            PersistentConversationDataItem.deleteConversationsUnchecked([conversationSid], inContext: managedObjectContext)
        } else {
            // Update conversation participant stats
            if let _ = PersistentConversationDataItem.from(conversation: conversation, inContext: managedObjectContext) {
                coreDataManager.saveContext()
            }
        }
    }
}
