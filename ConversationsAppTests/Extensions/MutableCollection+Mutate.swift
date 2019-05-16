//
//  MutableCollection+Mutate.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

extension MutableCollection {
    mutating func mutateEach(_ mutation: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try mutation(&self[index])
        }
    }
}
