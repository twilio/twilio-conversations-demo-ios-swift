//
//  ConversationDetailsActionCellTableViewCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class ConversationDetailsActionCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    var segueToPerform: String?
    var cellAction: ConversationDetailsCellAction?

    func setup(with model: ConversationDetailsActionCellViewModel) {
        cellImageView.image = model.cellImage
        cellTitle.text = model.cellTitle
        segueToPerform = model.segueToPerform
        cellAction = model.cellAction
    }
}
