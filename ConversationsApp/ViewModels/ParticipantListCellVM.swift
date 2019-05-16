//
//  ParticipantListCellVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ParticipantListCellViewModel {

    // MARK: Properties

    var cellImage: UIImage?
    var cellTitle: String
    var cellSubtitle: String
    var participant: TCHParticipant

    // MARK: Intialization

    init(cellImage: UIImage? = UIImage(named: "demo_avatar"), cellTitle: String, cellSubtitle: String = "", participant: TCHParticipant) {
        self.cellImage = cellImage
        self.cellTitle = cellTitle
        self.cellSubtitle = cellSubtitle
        self.participant = participant
    }
}
