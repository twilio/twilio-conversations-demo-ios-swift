//
//  UIImage+Ext.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    func loadImage(mediaSid: String, at url: URL,  onLoaded: ((Error?) -> Void)?) {
        UIImageLoader.loader.load(forMediaSid: mediaSid, url: url, for: self, onLoaded: onLoaded)
    }
    
    func cancelImageLoad() {
        UIImageLoader.loader.cancel(for: self)
    }
}
