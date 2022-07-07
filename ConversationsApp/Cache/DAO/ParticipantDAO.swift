//
//  ParticipantDAO.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

protocol ParticipantDAOProtocol {}

extension AppModel: ParticipantDAOProtocol {

    func getParticipants(inConversation conversationSid: String) -> ObservableResultPublisher<PersistentParticipantDataItem> {
        let fetchRequest: NSFetchRequest<PersistentParticipantDataItem> = PersistentParticipantDataItem.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "conversationSid = %@ ", conversationSid)
        return ObservableResultPublisher<PersistentParticipantDataItem>(with: fetchRequest, context: getManagedContext())
    }
    
    private func getParticipantsWithSids(sids: [String]) -> ObservableResultPublisher<PersistentParticipantDataItem> { // FIXME: BySids, not WithSids
        let fetchRequest: NSFetchRequest<PersistentParticipantDataItem> = PersistentParticipantDataItem.fetchRequest()
        let predicates: [NSPredicate] = sids.compactMap { NSPredicate(format: "sid = %@", $0) }
        fetchRequest.predicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        fetchRequest.sortDescriptors = []
        return ObservableResultPublisher<PersistentParticipantDataItem>(with: fetchRequest, context: getManagedContext())
    }
}
