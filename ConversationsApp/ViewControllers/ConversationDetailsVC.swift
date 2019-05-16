//
//  ConversationDetailsVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ConversationDetailsVC: UIViewController {

    // MARK: Interface Builder outlets

    @IBOutlet weak var detailsTitleLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var actionsTableView: UITableView!

    // MARK: Properties

    var conversationSid = ""
    private lazy var conversationDetailsViewModel = ConversationDetailsViewModel(conversationSid: conversationSid)

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        conversationDetailsViewModel.delegate = self
        actionsTableView.delegate = self
        actionsTableView.dataSource = conversationDetailsViewModel
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToParticipantList", let participantListVC = segue.destination as? ParticipantListVC {
            participantListVC.conversationSid = self.conversationSid
        }
    }

    // MARK: Methods

    func showAddParticipantAlert() {
        let addParticipantAlert = UIAlertController(
            title: NSLocalizedString("Add participant", comment: "Alert for adding new participant to conversation"),
            message: nil,
            preferredStyle: .alert
        )
        addParticipantAlert.addTextField {
            $0.placeholder = NSLocalizedString("Enter participant identity", comment: "Placeholder for participant identity")
        }
        addParticipantAlert.addAction(UIAlertAction(
            title: NSLocalizedString("Add", comment: "Action for renaming conversation"),
            style: .default,
            handler: { (_) in
                if let identity: String = addParticipantAlert.textFields?[0].text, identity != "" {
                    self.conversationDetailsViewModel.addParticipant(identity)
                }
        }))
        addParticipantAlert.addAction(UIAlertAction(
            title:  NSLocalizedString("Cancel", comment: "Title for canceling current action"),
            style: .cancel,
            handler: nil
        ))
        self.present(addParticipantAlert, animated: true)
    }

    func showRenameConversationAlert() {
        let renameAlert = UIAlertController(
            title: NSLocalizedString("Rename conversation", comment: "Alert for renaming conversation"),
            message: nil,
            preferredStyle: .alert
        )
        renameAlert.addTextField {
            $0.placeholder = NSLocalizedString("Enter new name", comment: "Placeholder for new conversation name")
        }
        renameAlert.addAction(UIAlertAction(
            title: NSLocalizedString("Rename", comment: "Action for renaming conversation"),
            style: .default,
            handler: { (_) in
                if let conversationNewName: String = renameAlert.textFields?[0].text, conversationNewName != "" {
                    self.conversationDetailsViewModel.renameConversation(conversationNewName)
                }
        }))
        renameAlert.addAction(UIAlertAction(
            title:  NSLocalizedString("Cancel", comment: "Title for canceling current action"),
            style: .cancel,
            handler: nil
        ))
        self.present(renameAlert, animated: true)
    }

    func showDeleteConversationAlert() {
        let deleteConversationAlert = UIAlertController(
            title: NSLocalizedString("Are you sure you want to delete this conversation?", comment: "Alert for deleting conversation"),
            message: nil,
            preferredStyle: .alert
        )
        deleteConversationAlert.addAction(UIAlertAction(
            title: NSLocalizedString("Delete", comment: "Action for deleting conversation"),
            style: .destructive,
            handler: { (_) in
                self.conversationDetailsViewModel.deleteConversation()
                self.navigationController?.popToRootViewController(animated: true)
        }))
        deleteConversationAlert.addAction(UIAlertAction(
            title:  NSLocalizedString("Cancel", comment: "Title for canceling current action"),
            style: .cancel,
            handler: nil
        ))
        self.present(deleteConversationAlert, animated: true)
    }
}

extension ConversationDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! ConversationDetailsActionCell

        if let segueName = cell.segueToPerform {
            performSegue(withIdentifier: segueName, sender: self)
            return
        }

        guard let actionToPerform = cell.cellAction else {
            return
        }

        switch actionToPerform {
        case .addParticipant:
            showAddParticipantAlert()
            break
        case .renameConversation:
            showRenameConversationAlert()
            break
        case .muteConversation:
            self.conversationDetailsViewModel.muteConversation()
            break
        case .deleteConversation:
            showDeleteConversationAlert()
            break
        }
    }
}

extension ConversationDetailsVC: ConversationDetailsViewModelListener {
    func onParticipantAdded(identity: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Participant Added", comment: "Alert title for confirmation of participant added"),
                                       message: NSLocalizedString("\(identity) was added to the conversation", comment: "Participant was added"),
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledgment that the participant was added"), style: .default))
            self.present(ac, animated: true)
        }
    }

    func onDisplayError(_ error: Error) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Error", comment: "Alert title message for occured error"), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledgment that this error message was read"), style: .default))
            self.present(ac, animated: true)
        }
    }

    func onConversationUpdated() {
        DispatchQueue.main.async {
            let name = self.conversationDetailsViewModel.observableConversation?.value?.first?.friendlyName ?? ""
            var date: String?
            if let createdAt = self.conversationDetailsViewModel.observableConversation?.value?.first?.dateCreated {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMMM yyyy"
                date = dateFormatter.string(from: createdAt)
            }

            self.detailsTitleLabel.text = "\(name) Info"
            self.detailsTextView.text = "Date: \(date ?? "No date available")"
        }
    }

    func onActionsListUpdate() {
        DispatchQueue.main.async {
            self.actionsTableView.reloadData()
        }
    }
}
