//
//  MessageDao+DeleteAll.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData
@testable import ConversationsApp

extension MessageDAOImpl {
    func clearData() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PersistentMessageDataItem")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try! coreDataContext.execute(request)
    }
}
