//
//  CredentialStorage+Ext.swift
//  ConversationsAppTests
//
//  Created by Ilia Kolomeitsev on 18.05.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import Foundation
@testable import ConversationsApp

extension CredentialStorage {

    func credentialsExist(identity: String, password: String) -> Bool {
        do {
            let loadedPass = try loadCredentials(identity: identity)
            return loadedPass == password ? true : false
        } catch {
            return false
        }
    }
}
