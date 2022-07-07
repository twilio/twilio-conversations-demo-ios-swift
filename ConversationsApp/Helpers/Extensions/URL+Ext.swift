//
//  URL+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

extension URL {

    var associatedMimeType: String? {
        if pathExtension == "png" {
            return "image/png"
        } else if pathExtension == "jpg" || pathExtension == "jpeg" {
            return "image/jpeg"
        }
        return nil
    }
}
