//
//  NewConversationVC.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 21.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class NewConversationVC: UIViewController {

    @IBOutlet weak var convoInputView: ConvoInputView!
    @IBOutlet weak var errorLabel: UILabel!

    var conversationListViewModel: ConversationListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        convoInputView.title = NSLocalizedString("Conversation name", comment: "Conversation name input title")
        convoInputView.placeholder = NSLocalizedString("Conversation name", comment: "Conversation name placeholder")
        errorLabel.text = nil
    }

    @IBAction func onCreateConversation(_ sender: Any) {
        guard let conversationName = convoInputView.text, !conversationName.isEmpty else {
            view.layoutIfNeeded()
            errorLabel.text = NSLocalizedString("Add a conversation title to create a conversation.",
                                                comment: "Conversation name is empty error")
            convoInputView.inputState = .error
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            return
        }

        conversationListViewModel.createAndJoinConversation(friendlyName: conversationName) { error in
            if let error = error {
                self.errorLabel.text = error.localizedDescription
            } else {
                self.dismiss(animated: true)
            }
        }
    }

    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true)
    }
}
