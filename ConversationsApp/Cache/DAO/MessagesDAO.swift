//
//  MessagesDAO.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

protocol MessagesDAOProtocol {

    func getObservableMessageWithUuid(_ messageUUID: UUID) -> ObservableResultPublisher<PersistentMessageDataItem>
    func getObservableConversationMessages(by sid: String) -> ObservableResultPublisher<PersistentMessageDataItem>

    func getMessageWithSid(_ sid: String) -> PersistentMessageDataItem?
    func getMessageWithIndex(messageIndex: NSNumber, onConversation: String) -> PersistentMessageDataItem?
}

extension AppModel: MessagesDAOProtocol {

    func getObservableConversationMessages(by sid: String) -> ObservableResultPublisher<PersistentMessageDataItem> {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversationSid = %@", sid)
        fetchRequest.sortDescriptors = []
        return ObservableResultPublisher<PersistentMessageDataItem>(with: fetchRequest, context: getManagedContext())
    }

    func getMessageWithSid(_ sid: String) -> PersistentMessageDataItem? {
        return nil
    }

    func getObservableMessageWithUuid(_ messageUUID: UUID) -> ObservableResultPublisher<PersistentMessageDataItem> {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", messageUUID.uuidString)
        fetchRequest.sortDescriptors = []
        return ObservableResultPublisher<PersistentMessageDataItem>(with: fetchRequest, context:  getManagedContext())
    }

    func getMessageWithIndex(messageIndex: NSNumber, onConversation conversationSid: String) -> PersistentMessageDataItem? {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[
                                                        NSPredicate(format: "index = %@", messageIndex),
                                                        NSPredicate(format: "conversationSid = %@", conversationSid)
                                                     ])

        fetchRequest.sortDescriptors = []
        return nil
    }

    // MARK: - Helpers
    private func getObservableMessages(_ messageSids: [String]) -> ObservableResultPublisher<PersistentMessageDataItem> {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        let predicates: [NSPredicate] = messageSids.compactMap { NSPredicate(format: "sid = %@", $0) }
        fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        fetchRequest.sortDescriptors = []
        return ObservableResultPublisher<PersistentMessageDataItem>(with: fetchRequest, context:  getManagedContext())
    }
}
