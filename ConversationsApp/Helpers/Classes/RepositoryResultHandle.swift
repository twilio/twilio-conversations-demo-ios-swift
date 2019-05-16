//
//  RepositoryResultHandle.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import CoreData

class RepositoryResultHandle<T> where T: NSFetchRequestResult {

    let data: ObservableFetchRequestResult<T>
    let requestStatus = Observable<RepositoryFetchStatus>()

    init(with value: ObservableFetchRequestResult<T>) {
        requestStatus.value = .notStarted
        data = value
    }
}
