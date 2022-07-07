//
//  CoreDataManager.swift
//  ConversationsApp
//
//  Created by Cece Laitano on 4/4/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataDelegate {
    var managedObjectContext: NSManagedObjectContext { get }
    func saveContext()
}

class CoreDataManager: CoreDataDelegate {
    
    let persistentContainer: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "ConversationsApp")
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // No need for @Published as a property derived from an existing @Published property is itself
    // automatically @Published.
    var managedObjectContext: NSManagedObjectContext {
        get {
            persistentContainer.viewContext
        }
    }
    
    func saveContext() {
        managedObjectContext.perform {
            if self.managedObjectContext.hasChanges {
                do {
                    NSLog("Saving data")
                    try self.managedObjectContext.save()
                } catch {
                    /* This is straight out of Apple's default implementation. As such Apple advises to replace
                     * this implementation with code to handle the error appropriately.
                     * In particular fatalError() will causes the application to generate a crash log and terminate.
                     */
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
