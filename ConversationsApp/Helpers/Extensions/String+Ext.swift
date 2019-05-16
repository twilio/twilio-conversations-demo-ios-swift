//
//  String+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

extension String {

    func toDictionary() -> [String: Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }

        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        } catch {
            //TODO: Optionally handle error
            print("Unhandled error: ", error.localizedDescription)
            return nil
        }
    }
}
