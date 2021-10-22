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

    private var debounceTask: DispatchWorkItem?

    init(withContext context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        coreDataContext = context
    }

    func save() {
        debounceTask?.cancel()

        debounceTask = DispatchWorkItem { [weak self] in
            guard let self = self else {
                return
            }

            if self.coreDataContext.hasChanges {
                do {
                    try self.coreDataContext.save()
                } catch {
                    if let error = error as NSError? {
                        // TODO: Add proper error handling
                        print("Unresolved error: \(error), \(error.userInfo)")
                    }
                }
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: debounceTask!)
    }

}
