//
//  DateFormatter+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

extension DateFormatter {

    func createDateString(from date: TimeInterval, format: String) -> String {
        dateFormat = format
        return string(from: Date(timeIntervalSince1970: date))
    }
}
