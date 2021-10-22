//
//  MessagesDAO.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

protocol MessageDAO {

    func getObservableMessageWithUuid(_ messageUUID: String) -> ObservableFetchRequestResult<PersistentMessageDataItem>
    func getObservableConversationMessages(by sid: String) -> ObservableFetchRequestResult<PersistentMessageDataItem>
    func deleteMessages(by messageSids: [String])
    func upsertMessages(_ items: [MessageDataItem])
    func getMessageWithSid(_ sid: String) -> PersistentMessageDataItem?
    func getMessageWithIndex(messageIndex: NSNumber, onConversation: String) -> PersistentMessageDataItem?
}

class MessageDAOImpl: BaseDAO, MessageDAO {

    func getObservableConversationMessages(by sid: String) -> ObservableFetchRequestResult<PersistentMessageDataItem> {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversationSid = %@", sid)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentMessageDataItem>(with: fetchRequest)
    }

    func getMessageWithSid(_ sid: String) -> PersistentMessageDataItem? {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sid =%@", sid)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentMessageDataItem>(with: fetchRequest).value?.first
    }

    func getObservableMessageWithUuid(_ messageUUID: String) -> ObservableFetchRequestResult<PersistentMessageDataItem> {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", messageUUID)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentMessageDataItem>(with: fetchRequest)
    }

    func upsertMessages(_ items: [MessageDataItem]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        items.forEach { (toBeInserted) in
            let cachedResult = getObservableMessageWithUuid(toBeInserted.uuid).value
            if let toBeUpdated = cachedResult?.first(where: { $0.uuid == toBeInserted.uuid }) {
                toBeUpdated.setup(with: toBeInserted)
            } else {
                let _ = PersistentMessageDataItem(with: toBeInserted, insertInto: coreDataContext)
            }
        }
        save()
    }

    func deleteMessages(by messageSids: [String]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let cachedResults = getObservableMessages(messageSids).value
        cachedResults?.forEach { coreDataContext.delete($0) }
        save()
    }

    func getMessageWithIndex(messageIndex: NSNumber, onConversation conversationSid: String) -> PersistentMessageDataItem? {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[
                                                        NSPredicate(format: "index = %@", messageIndex),
                                                        NSPredicate(format: "conversationSid = %@", conversationSid)
                                                     ])

        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentMessageDataItem>(with: fetchRequest).value?.first
    }

    // MARK: - Helpers
    private func getObservableMessages(_ messageSids: [String]) -> ObservableFetchRequestResult<PersistentMessageDataItem> {
        let fetchRequest: NSFetchRequest<PersistentMessageDataItem> = PersistentMessageDataItem.fetchRequest()
        let predicates: [NSPredicate] = messageSids.compactMap { NSPredicate(format: "sid = %@", $0) }
        fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentMessageDataItem>(with: fetchRequest)
    }
}
