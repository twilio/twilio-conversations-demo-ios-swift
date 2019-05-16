//
//  BaseDAO.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

class BaseDAO {

    let coreDataContext: NSManagedObjectContext

    init(withContext context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        coreDataContext = context
    }

    func save() {
        if coreDataContext.hasChanges {
            do {
                try coreDataContext.save()
            } catch {
                if let error = error as NSError? {
                    // TODO: Add proper error handling
                    print("Unresolved error: \(error), \(error.userInfo)")
                }
            }
        }
    }

}
