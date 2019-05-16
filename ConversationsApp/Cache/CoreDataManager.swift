//
//  CoreDataManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()
    let viewContext: NSManagedObjectContext!

    private init() {
        let container = NSPersistentContainer(name: "ConversationsApp")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        viewContext = container.viewContext
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
