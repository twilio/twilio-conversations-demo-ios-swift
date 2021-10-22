//
//  ConversationListCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class ConversationListCell: UITableViewCell {

    @IBOutlet weak var friendlyName: UILabel!
    @IBOutlet weak var participantsCount: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    @IBOutlet weak var unreadMessageCount: UILabel!
    @IBOutlet weak var unreadContainer: UIView!
    @IBOutlet weak var deliveryStatusImage: UIImageView!
    @IBOutlet weak var mediaPreviewImage: UIImageView!
    @IBOutlet weak var muteStateImage: UIImageView!
    
    func setup(with model: ConversationListCellViewModel) {
        selectionStyle = .none

        friendlyName.text = model.name
        participantsCount.text = model.participantsCount
        lastMessageDate.text = model.lastMessageDate
        unreadMessageCount.text = "\(model.unreadMessageCount)"

        let processDeliveryStatus = { [self] (deliveryStatus: ConversationListCellViewModel.MessageType.MessageStatus) in
            setMessagePreviewState(.default)
            switch deliveryStatus {
            case .received:
                deliveryStatusImage.isHidden = true
            case .sent(let sentStatus):
                deliveryStatusImage.isHidden = false
                switch sentStatus {
                case .error(.other):
                    break
                case .error(.failedToSend):
                    setMessagePreviewState(.error)
                    deliveryStatusImage.image = UIImage(systemName: "exclamationmark.square.fill")
                case .delivered:
                    deliveryStatusImage.image = UIImage(systemName: "checkmark")
                case .sending:
                    deliveryStatusImage.image = UIImage(systemName: "ellipsis")
                case .sent:
                    deliveryStatusImage.image = UIImage(systemName: "checkmark")
                }
            }
        }

        switch model.lastMessageState {
        case .none:
            lastMessage.text = ""
            mediaPreviewImage.isHidden = true
            deliveryStatusImage.isHidden = true
        case .media(let identity, let deliveryStatus):
            let author = identity ?? NSLocalizedString("You", comment: "User of the app shared a media")
            lastMessage.text = NSLocalizedString("\(author) shared a media", comment: "Someone shared a media")
            mediaPreviewImage.isHidden = false

            processDeliveryStatus(deliveryStatus)
        case .text(let body, let deliveryStatus):
            lastMessage.text = body
            mediaPreviewImage.isHidden = true

            processDeliveryStatus(deliveryStatus)
        }

        if model.unreadMessageCount > 0 {
            let roundness = lastMessageDate.frame.height / 2
            unreadContainer.layer.cornerRadius = roundness
            unreadContainer.isHidden = false
            lastMessageDate.isHidden = false

            setMessagePreviewState(.unread)
        } else {
            unreadContainer.isHidden = true
            lastMessageDate.isHidden = true
        }

        switch model.notificationLevel {
        case .default:
            muteStateImage.isHidden = true
            friendlyName.textColor = .textColor
        case .muted:
            muteStateImage.isHidden = false
            friendlyName.textColor = .weakTextColor
        }
    }

    private func setMessagePreviewState(_ messagePreviewState: MessagePreviewState) {
        switch messagePreviewState {
        case .default:
            deliveryStatusImage.tintColor = UIColor.weakTextColor
            mediaPreviewImage.tintColor = UIColor.weakTextColor
            lastMessage.textColor = UIColor.weakTextColor
            lastMessageDate.textColor = UIColor.weakTextColor
        case .unread:
            deliveryStatusImage.tintColor = UIColor.linkIconColor
            mediaPreviewImage.tintColor = UIColor.linkIconColor
            lastMessage.textColor = UIColor.linkTextColor
            lastMessageDate.textColor = UIColor.linkTextColor
        case .error:
            deliveryStatusImage.tintColor = UIColor.errorIconColor
            mediaPreviewImage.tintColor = UIColor.errorIconColor
            lastMessage.textColor = UIColor.errorTextColor
            lastMessageDate.textColor = UIColor.weakTextColor
        }
    }

    enum MessagePreviewState {
        case `default`, unread, error
    }
}
