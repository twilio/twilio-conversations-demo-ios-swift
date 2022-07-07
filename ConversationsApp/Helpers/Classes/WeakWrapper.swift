//
//  WeakWrapper.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

@propertyWrapper
class WeakWrapper<T> where T: AnyObject {

    private weak var value: T?

    var wrappedValue: T? {
        get {
            value
        }
    }

    init(wrappedValue value: T?) {
        self.value = value
    }
}
