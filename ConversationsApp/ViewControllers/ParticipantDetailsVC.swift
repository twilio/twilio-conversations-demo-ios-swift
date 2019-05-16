//
//  ParticipantDetailsVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ParticipantDetailsVC: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var participantSinceTitleLabel: UILabel!
    @IBOutlet weak var participantSinceLabel: UILabel!
    @IBOutlet weak var participantStatusTitleLabel: UILabel!
    @IBOutlet weak var participantStatusLabel: UILabel!

    var participantListViewModel: ParticipantListViewModel?
    var participant: TCHParticipant? {
        didSet {
            participant?.subscribedUser(completion: { (result, user) in
                self.fillViewWithParticipantDetails(user)
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        removeButton.layer.cornerRadius = 10
        participantSinceTitleLabel.text = NSLocalizedString("Participant Since", comment: "Title for time since user is a participant")
        participantStatusTitleLabel.text = NSLocalizedString("Status", comment: "Title for user online/offline status")
    }

    private func fillViewWithParticipantDetails(_ user: TCHUser?) {
        DispatchQueue.main.async {
            self.participantNameLabel.text = self.participant?.identity ?? ""
            self.participantSinceLabel.text = "-"
            self.participantStatusLabel.text = user?.isOnline() ?? false ?
                NSLocalizedString("Online", comment: "User online state") :
                NSLocalizedString("Offline", comment: "User offline state")
        }
    }

    @IBAction func removeTapped(_ sender: Any) {
        guard let participant = participant else {
            return
        }
        participantListViewModel?.remove(participant: participant)
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
