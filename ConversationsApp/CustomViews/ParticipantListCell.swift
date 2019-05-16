//
//  ParticipantListCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ParticipantListCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellSubtitle: UILabel!

    var participant: TCHParticipant?

    func setup(with model: ParticipantListCellViewModel) {
        cellImageView.image = model.cellImage
        cellTitle.text = model.cellTitle
        cellSubtitle.text = model.cellSubtitle
        self.participant = model.participant
    }

    func setup(with participantItem: ParticipantDataItem) {
        cellTitle.text = participantItem.identity
        cellSubtitle.isHidden = true
        cellImageView.image = UIImage(named: "demo_avatar")
    }
}
