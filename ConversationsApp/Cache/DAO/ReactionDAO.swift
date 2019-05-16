//
//  ReactionDAO.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

protocol ReactionDAO {
    func getReactions(onMessage messageSid: String, withType reactionType: ReactionType) -> ObservableFetchRequestResult<PersistentMessageReactionDataItem>
}

class ReactionDAOImpl:  BaseDAO, ReactionDAO {
    func getReactions(onMessage messageSid: String, withType reactionType: ReactionType) -> ObservableFetchRequestResult<PersistentMessageReactionDataItem> {
        let fetchRequest: NSFetchRequest<PersistentMessageReactionDataItem> = PersistentMessageReactionDataItem.fetchRequest()
        let predicates: [NSPredicate] = [ NSPredicate(format: "message.sid = %@", messageSid),
                                          NSPredicate(format: "reactionType = %@", reactionType.rawValue) ]
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        fetchRequest.sortDescriptors = []
        return ObservableFetchRequestResult<PersistentMessageReactionDataItem>(with: fetchRequest)
    }
}
