//
//  Operation.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
import Foundation

// Function that is executed once the Operation is executed
typealias Callback<T> = (Result<T, Error>) -> Void

// Function that takes type V as parameters and execute callback with result type T
struct AsyncOperation<V, T> {

    let input: V
    let task: (V, @escaping Callback<T>) -> Void
}

func retry<V, T>(operation: AsyncOperation<V, T>,
                 callback: @escaping Callback<T>,
                 intervalBetweenRetries: TimeInterval = 3,
                 numberOfTries: Int = 3,
                 queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)) {
    queue.asyncAfter(deadline: .now()) {
        operation.task(operation.input) { result in
            switch result {
            case .success(let t):
                callback(.success(t))
            case .failure(let error):
                if numberOfTries > 1 {
                    queue.asyncAfter(deadline: .now() + intervalBetweenRetries) {
                        retry(operation: operation, callback: callback, numberOfTries: numberOfTries - 1)
                    }
                } else {
                    callback(.failure(error))
                }
            }
        }
    }
}

