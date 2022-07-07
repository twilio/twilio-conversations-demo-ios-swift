//
//  UIImage+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    func loadImage(mediaSid: String, at url: URL,  onLoaded: ((UIImage?, Error?) -> Void)?) {
        UIImageLoader.loader.load(forMediaSid: mediaSid, url: url, onLoaded: onLoaded)
    }
    
    func cancelImageLoad() {
        UIImageLoader.loader.cancel(for: self)
    }
}
