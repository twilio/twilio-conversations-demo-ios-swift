//
//  ConversationDAO.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData
import TwilioConversationsClient

protocol ConversationDAO {
    func insertOrUpdate(_ items: [ConversationDataItem])
    func delete(_ conversationSids: [String])
    func clearConversationList()
    func getObservableConversationList() -> ObservableFetchRequestResult<PersistentConversationDataItem>
    func getObservableConversations(_ conversationSids: [String]) -> ObservableFetchRequestResult<PersistentConversationDataItem>
    func getConversationDataItem(sid: String) -> ConversationDataItem?
}

class ConversationDAOImpl: BaseDAO, ConversationDAO  {

    func insertOrUpdate(_ items: [ConversationDataItem]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        items.forEach { (toBeInserted) in
            let cachedResult = getObservableConversations([toBeInserted.sid])
            if let toBeUpdated = cachedResult.value?.first(where: { $0.sid == toBeInserted.sid }) {
                NSLog("[\(toBeInserted.sid)] will be updated")
                toBeUpdated.update(with: toBeInserted)
            } else {
                NSLog("[\(toBeInserted.sid)] will be inserted")
                let _ = PersistentConversationDataItem(with: toBeInserted, insertInto: coreDataContext)
            }
        }
        save()
    }

    func delete(_ conversationSids: [String]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let cachedResults = getObservableConversations(conversationSids).value
        cachedResults?.forEach { coreDataContext.delete($0) }
        save()
    }
    
    func clearConversationList() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let fetchRequest: NSFetchRequest<PersistentConversationDataItem> = PersistentConversationDataItem.fetchRequest()
        let cachedResults = try! coreDataContext.fetch(fetchRequest)
        cachedResults.forEach { coreDataContext.delete($0) }
        save()
    }
    
    func getObservableConversationList() -> ObservableFetchRequestResult<PersistentConversationDataItem> {
        let fetchRequest: NSFetchRequest<PersistentConversationDataItem> = PersistentConversationDataItem.fetchRequest()
        fetchRequest.sortDescriptors = []

        return ObservableFetchRequestResult<PersistentConversationDataItem>(with: fetchRequest)
    }
    
    func getObservableConversations(_ conversationSids: [String]) -> ObservableFetchRequestResult<PersistentConversationDataItem> {
        let fetchRequest: NSFetchRequest<PersistentConversationDataItem> = PersistentConversationDataItem.fetchRequest()
        let predicates: [NSPredicate] = conversationSids.compactMap { NSPredicate(format: "sid = %@", $0) }
        fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentConversationDataItem>(with: fetchRequest)
    }
    
    func getConversationDataItem(sid: String) -> ConversationDataItem? {
        return getObservableConversations([sid]).value?.first?.getConversationDataItem()
    }
}
