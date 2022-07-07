//
//  NotificationService.swift
//  PushNotificationServiceExtension
//
//  Created by Pavel Cherentcov on 18.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var updatedContent: UNMutableNotificationContent?

    private static func makeIconForMediaNotification(_ mediaCount: Int, _ contentType: String) -> UNNotificationAttachment {
        enum NotificationIcons: String {
            case multipleAttachments = "multiple-attachments"
            case imageAttachment = "image"
            case videoAttachment = "video"
            case audioAttachment = "audio"
            case someAttachment = "document"

            var iconUrl: URL? {
                return Bundle.main.url(forResource: rawValue, withExtension: "png")
            }
        }

        var icon: NotificationIcons

        if mediaCount > 1 {
            icon = .multipleAttachments
        }
        else {
            if contentType.starts(with: "image/") {
                icon = .imageAttachment
            } else if contentType.starts(with: "video/") {
                icon = .videoAttachment
            } else if contentType.starts(with: "audio/") {
                icon = .audioAttachment
            }
            else {
                icon = .someAttachment
            }
        }

        return try! UNNotificationAttachment(identifier: "icon", url: icon.iconUrl!)
    }

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        // "mutable-content" flag should be set to 1
        self.contentHandler = contentHandler
        updatedContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = request.content.userInfo

        guard let updatedContent = self.updatedContent, let messageType = userInfo["twi_message_type"] as? String else {
            contentHandler(request.content)
            return
        }
        
        // You can modify the notification content here...

        // We have kept the notifications fairly minimal, relying more on the Push Configuration in the Twilio Console.
        
        updatedContent.title = ""
        updatedContent.subtitle = ""

        // Display media details in notification
        if messageType == "twilio.conversations.new_message",
           let mediaCount = userInfo["media_count"] as? Int,
           let media = userInfo["media"] as? [String : Any],
           let contentType = media["content_type"] as? String {

            updatedContent.attachments = [NotificationService.makeIconForMediaNotification(mediaCount, contentType)]
        }

        contentHandler(updatedContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let updatedContent =  updatedContent {
            contentHandler(updatedContent)
        }
    }

}
