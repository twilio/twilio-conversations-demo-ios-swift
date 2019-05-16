//
//  ConversationDetailsActionCellViewModel.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

enum ConversationDetailsCellAction {
    case addParticipant
    case renameConversation
    case muteConversation
    case deleteConversation
}

class ConversationDetailsActionCellViewModel {

    // MARK: Properties

    var cellImage: UIImage
    var cellTitle: String
    var segueToPerform: String?
    var cellAction: ConversationDetailsCellAction?

    // MARK: Intialization

    init(cellImage: UIImage, cellTitle: String, segueToPerform: String? = nil, action: ConversationDetailsCellAction? = nil) {
        self.cellImage = cellImage
        self.cellTitle = cellTitle
        self.segueToPerform = segueToPerform
        self.cellAction = action
    }
}
