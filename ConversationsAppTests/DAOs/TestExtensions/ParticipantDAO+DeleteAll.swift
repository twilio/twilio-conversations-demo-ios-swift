//
//  ParticipantDAO+DeleteAll.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData
@testable import ConversationsApp

extension ParticipantDAOImpl {
    func clearData() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentParticipantDataItem")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try! coreDataContext.execute(request)
    }
}
