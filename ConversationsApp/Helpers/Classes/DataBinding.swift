//
//  DataBinding.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import CoreData

class Observable<T> {

    var value: T? {
        didSet {
            notifyObservers()
        }
    }

    private var observers: [ObserverContainer<T>] = []

    init(_ v: T? = nil) {
        value = v
    }

    func observe(with owner: AnyObject, _ onChanged: @escaping (T?) -> (Void)) {
        observers.append(ObserverContainer(owner: owner, onChanged: onChanged))
        onChanged(value)
    }

    func removeObserver(_ owner: AnyObject) {
        observers.removeAll { $0.owner === owner }
    }

    func notifyObservers() {
        observers.removeAll { $0.owner == nil }
        observers.forEach { $0.onChanged(value) }
    }
}

class ObserverContainer<T> {

    weak var owner: AnyObject?
    let onChanged: (T?) -> (Void)

    init(owner: AnyObject, onChanged: @escaping (T?) -> (Void)) {
        self.owner = owner
        self.onChanged = onChanged
    }
}

class ObservableFetchRequestResult<T>: NSObject, NSFetchedResultsControllerDelegate where T: NSFetchRequestResult {

    private var observers: [ObserverContainer<[T]>] = []
    private var fetchedResultsController: NSFetchedResultsController<T>?

    var value: [T]? {
        get {
            return fetchedResultsController?.fetchedObjects
        }
    }

    override private init() {}

    init(with request: NSFetchRequest<T>) {
        super.init()

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: CoreDataManager.shared.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Unhandled error: ", error)
        }
    }

    func observe(with owner: AnyObject, _ onChanged: @escaping ([T]?) -> (Void)) {
        observers.append(ObserverContainer(owner: owner, onChanged: onChanged))
        print("observers count after appending \(observers.count), \(self)")
        onChanged(value)
    }

    func removeObserver(_ owner: AnyObject) {
        observers.removeAll { $0.owner === owner }
    }

    private func notifyObservers() {
        observers.removeAll { $0.owner == nil }
        observers.forEach { $0.onChanged(value) }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.global().async {
            self.notifyObservers()
        }
    }
}
