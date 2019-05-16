//
//  Dictionary+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {

    func toString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            //TODO: Optionally handle error
            print("Unhandled error: ", error.localizedDescription)
            return nil
        }
    }
}
