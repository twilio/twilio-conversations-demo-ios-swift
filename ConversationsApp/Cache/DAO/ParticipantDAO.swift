//
//  ParticipantDAO.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

protocol ParticipantDAO {
    func getParticipants(inConversation conversationSid: String) -> ObservableFetchRequestResult<PersistentParticipantDataItem>
    func getTypingParticipants(inConversation conversationSid: String) -> ObservableFetchRequestResult<PersistentParticipantDataItem>
    func upsertParticipants(_ participant: [ParticipantDataItem])
    func updateIsTyping(for participantSid: String, isTyping: Bool)
}

class ParticipantDAOImpl: BaseDAO, ParticipantDAO {

    func updateIsTyping(for participantSid: String, isTyping: Bool) {
        let cachedParticipant = getParticipantsWithSids(sids:[participantSid]).value?.first
        guard let participantToUpdate = cachedParticipant else {
           return
        }
        participantToUpdate.isTyping = isTyping
        save()
    }

    func getParticipants(inConversation conversationSid: String) -> ObservableFetchRequestResult<PersistentParticipantDataItem> {
        let fetchRequest: NSFetchRequest<PersistentParticipantDataItem> = PersistentParticipantDataItem.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "conversationSid = %@ ", conversationSid)
        return ObservableFetchRequestResult<PersistentParticipantDataItem>(with: fetchRequest)
    }
    
    private func getParticipantsWithSids(sids: [String]) -> ObservableFetchRequestResult<PersistentParticipantDataItem> {
        let fetchRequest: NSFetchRequest<PersistentParticipantDataItem> = PersistentParticipantDataItem.fetchRequest()
        let predicates: [NSPredicate] = sids.compactMap { NSPredicate(format: "sid = %@", $0) }
        fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentParticipantDataItem>(with: fetchRequest)
    }
    
    func upsertParticipants(_ participantsToUpdate: [ParticipantDataItem]) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        if (participantsToUpdate.count == 0) {
            return
        }
        
        let cachedParticipants = getParticipantsWithSids(sids: participantsToUpdate.map{$0.sid}).value
        participantsToUpdate.forEach { participantToInsertOrUpdate in
            if let toBeUpdated = cachedParticipants?.first(where: { $0.sid == participantToInsertOrUpdate.sid}) {
                toBeUpdated.update(with: participantToInsertOrUpdate)
            } else {
                let _ = PersistentParticipantDataItem(with: participantToInsertOrUpdate, insertInto: coreDataContext)
            }
        }
        save()
    }
    
    func getTypingParticipants(inConversation conversationSid: String) -> ObservableFetchRequestResult<PersistentParticipantDataItem> {
        let fetchRequest: NSFetchRequest<PersistentParticipantDataItem> = PersistentParticipantDataItem.fetchRequest()
        let predicates: [NSPredicate] = [ NSPredicate(format: "conversationSid = %@", conversationSid),
                                          NSPredicate(format: "isTyping = YES") ]
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentParticipantDataItem>(with: fetchRequest)
    }
}
