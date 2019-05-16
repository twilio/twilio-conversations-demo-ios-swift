//
//  JoinedConversationListCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class JoinedConversationListCell: UITableViewCell {

    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var friendlyName: UILabel!
    @IBOutlet weak var participantsCount: UILabel!
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    @IBOutlet weak var unreadMessageCount: UILabel!
    @IBOutlet weak var unreadContainer: UIView!

    func setup(with model: ConversationListCellViewModel) {
        friendlyName.text = model.friendlyName.isEmpty ? model.sid : model.friendlyName
        participantsCount.text = model.participantsCount
        dateCreated.text = model.dateCreated
        lastMessageDate.text = model.lastMessageDate
        unreadMessageCount.text = "\(model.unreadMessageCount)"
        if model.unreadMessageCount > 0 {
            unreadContainer.layer.cornerRadius = 5
            unreadContainer.isHidden = false
            lastMessageDate.isHidden = false
        } else {
            unreadContainer.isHidden = true
            lastMessageDate.isHidden = true
        }
        selectionStyle = .none
    }
}
