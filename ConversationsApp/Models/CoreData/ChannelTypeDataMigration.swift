//
//  ChannelTypeDataMigration.swift
//  ConversationsApp
//
//  Created by Alejandro Orozco Builes on 27/11/23.
//  Copyright © 2023 Twilio, Inc. All rights reserved.
//

import CoreData


class ChannelTypeDataMigration: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {

        guard sInstance.entity.name == "PersistentParticipantDataItem" else {
            return
        }
        
        let previousChannelType = sInstance.primitiveValue(forKey: "type") as? Int16 ?? 0

        let channel: String?

        switch Int(previousChannelType) {
            case 0:
                channel = nil
            case 1:
                channel = "other"
            case 2:
                channel = "chat"
            case 3:
                channel = "whatsapp"
            default:
                channel = nil
        }

        let attributes = sInstance.primitiveValue(forKey: "attributes") as? String
        let identity = sInstance.primitiveValue(forKey: "identity") as? String
        let lastReadMessage = sInstance.primitiveValue(forKey: "lastReadMessage") as? Int64

        guard
            let sid = sInstance.primitiveValue(forKey: "sid") as? String,
            let conversationSid = sInstance.primitiveValue(forKey: "conversationSid") as? String
        else {
            return
        }

        let newPersistentParticipantDataItem = NSEntityDescription.insertNewObject(forEntityName: "PersistentParticipantDataItem", into: manager.destinationContext)
        newPersistentParticipantDataItem.setValue(attributes, forKey: "attributes")
        newPersistentParticipantDataItem.setValue(identity, forKey: "identity")
        newPersistentParticipantDataItem.setValue(lastReadMessage, forKey: "lastReadMessage")
        newPersistentParticipantDataItem.setValue(sid, forKey: "sid")
        newPersistentParticipantDataItem.setValue(conversationSid, forKey: "conversationSid")
        newPersistentParticipantDataItem.setValue(channel, forKey: "channel")
    }
}
