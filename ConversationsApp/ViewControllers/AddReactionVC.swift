//
//  AddReactionVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ReactionDelegate: AnyObject {
    func onReactionSelected(reaction: ReactionType, for messageSid: String)
}

class AddReactionVC: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    weak var delegate: ReactionDelegate?
    
    private var messageToDisplay: MessageDataListItem!
    
    @IBAction func onDissmiss(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func onReactionTapped(_ sender: UIButton) {
        guard
            let reactionStr = sender.titleLabel?.text,
            let reaction = ReactionType(rawValue: reactionStr),
            let messageSid = messageToDisplay.sid else {
                return
        }
        delegate?.onReactionSelected(reaction: reaction, for: messageSid)
        dismiss()
    }
    
    func setMessage(withMessage message: MessageDataListItem) {
        messageToDisplay = message
        messageLabel.text = message.body
    }
    
    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
