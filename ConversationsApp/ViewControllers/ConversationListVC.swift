//
//  ConversationListVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ConversationListVC: UIViewController, UITableViewDelegate, ConversationListObserver, UISearchBarDelegate {

    // MARK: Interface Builder outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: Properties

    private let conversationListViewModel = ConversationListViewModel()
    private lazy var refreshControl = UIRefreshControl()

    // MARK: UIViewController

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = conversationListViewModel
        conversationListViewModel.delegate = self
        searchBar.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(requestRefreshConversationList), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onNotificationTap()
    }

    // MARK: Interface Builder actions

    @IBAction func addConversationPressed(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: NSLocalizedString("Options", comment: "Options on how to add new conversation"), message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: NSLocalizedString("Create conversation", comment: "Title for creating private conversation"), style: .default, handler: { (action) in
            self.createConversation()
        }))

        ac.addAction(UIAlertAction(title: NSLocalizedString("Join conversation by unique name", comment: "Title for joining conversation with unique name"), style: .default, handler: { (action) in
            self.joinConversationByUniqueName()
        }))

        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title for canceling current action"), style: .cancel, handler: nil))

        self.present(ac, animated: true)
    }

    @IBAction func menuButtonPressed(_ sender: Any) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        ac.addAction(UIAlertAction(title: NSLocalizedString("Profile", comment: "Title for profile button"), style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "showUserProfile", sender: self)
        }))

        ac.addAction(UIAlertAction(title: NSLocalizedString("Logout", comment: "Title for logout button"), style: .default, handler: { (action) in
            self.conversationListViewModel.signOut()
        }))

        ac.addAction(UIAlertAction(title: NSLocalizedString("Trigger app crash", comment: "Title for crash button"), style: .destructive, handler: { (action) in
            fatalError()
        }))

        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title for canceling current action"), style: .cancel, handler: nil))

        self.present(ac, animated: true)
    }

    // MARK: Functions

    private func createConversation() {
        let ac = UIAlertController(title: NSLocalizedString("Enter conversation name", comment: "Created conversation name"), message: nil, preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = NSLocalizedString("Conversation name", comment: "Placeholder for conversation name")
        }

        ac.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: "Action for creating a conversation"), style: .default, handler: { (action) in
            let conversationName: String? = ac.textFields?[0].text
            self.conversationListViewModel.createAndJoinConversation(friendlyName: conversationName)
        }))

        ac.addAction(UIAlertAction(title:  NSLocalizedString("Cancel", comment: "Title for canceling current action"), style: .cancel, handler: nil))

        self.present(ac, animated: true)
    }

    private func joinConversationByUniqueName() {
        let ac = UIAlertController(title: NSLocalizedString("Enter conversation unique name", comment: "Joined conversation unique name"), message: nil, preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = NSLocalizedString("Conversation unique name", comment: "Placeholder for conversation unique name")
        }

        ac.addAction(UIAlertAction(title: NSLocalizedString("Join", comment: "Action for joining a conversation"), style: .default, handler: { (action) in
            guard let conversationUniqueName: String = ac.textFields?[0].text else {
                return
            }
            self.conversationListViewModel.onJoinConversation(uniqueName: conversationUniqueName)
        }))

        ac.addAction(UIAlertAction(title:  NSLocalizedString("Cancel", comment: "Title for canceling current action"), style: .cancel, handler: nil))

        self.present(ac, animated: true)
    }

    // MARK: ConversationListObserver

    func onDataChanged() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func onDisplayError(_ error: Error) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Error", comment: "Alert title message for occured error"), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledgment that this error message was read"), style: .default))
            self.present(ac, animated: true)
        }
    }

    func onNotificationTap() {
        if let navigateToConversationWithSid = conversationListViewModel.getConversationSidToNavigateTo() {
            navigateToConversation(navigateToConversationWithSid)
        }
    }

    // MARK: Helpers

    func navigateToConversation(_ conversationSid: String) {
        guard
            let conversationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConversationVC") as? ConversationVC,
            let navigationController = self.navigationController
        else {
            fatalError("could not instantiate the ChannleVC UIViewController")
        }

        conversationVC.conversationSid = conversationSid
        DispatchQueue.main.async {
            navigationController.pushViewController(conversationVC, animated: true)
        }
    }

    // MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        conversationListViewModel.searchConversationList(contains: searchBar.text)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: Selector handles

    @objc func requestRefreshConversationList(refreshControl: UIRefreshControl) {
        conversationListViewModel.reloadConversationList()
        refreshControl.endRefreshing()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedConversation = self.conversationListViewModel.getDisplayedConversationAt(index: indexPath.row)
        navigateToConversation(selectedConversation.sid)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedConversation = conversationListViewModel.getDisplayedConversationAt(index: indexPath.row)

        let configuration = UISwipeActionsConfiguration(
            actions: [
                createAddParticipantAction(for: selectedConversation),
                createNotificationLevelAction(for: selectedConversation),
                createDestroyConversationAction(for: selectedConversation),
            ])
        return configuration
    }

    func createDestroyConversationAction(for conversationCell: ConversationListCellViewModel) -> UIContextualAction {
        let destroyAction = UIContextualAction(
            style: .destructive,
            title: NSLocalizedString("Destroy", comment: "Action for destroying conversation"),
            handler: { (action, view, completionHandler) in
                guard !conversationCell.userInteractionState.isDestroyingConversation else {
                    completionHandler(false)
                    return
                }
                self.conversationListViewModel.onDestroyConversation(sid: conversationCell.sid)
                completionHandler(true)
            })
        destroyAction.backgroundColor = UIColor(named: "DestroyConversationCellColor")
        return destroyAction
    }

    func createNotificationLevelAction(for conversationCell: ConversationListCellViewModel) -> UIContextualAction {
        let notificationTitle = conversationCell.notificationLevel == TCHConversationNotificationLevel.default ?
            NSLocalizedString("Mute", comment: "action for muting conversation"):
            NSLocalizedString("Unmute", comment: "action for unmuting conversation")

        let notificationLevelAction = UIContextualAction(
            style: .normal,
            title:  notificationTitle,
            handler: { (action, view, completionHandler) in
                guard !conversationCell.userInteractionState.isChangingNotificationLevel else {
                    completionHandler(false)
                    return
                }
                self.conversationListViewModel.onSetConversationNotificationLevel(
                    sid: conversationCell.sid,
                    level: conversationCell.notificationLevel == TCHConversationNotificationLevel.default
                        ? .muted
                        : .default)
                completionHandler(true)
            }
        )
        notificationLevelAction.backgroundColor = UIColor(named: "MuteConversationCellColor")
        return notificationLevelAction
    }

    func createAddParticipantAction(for conversationCell: ConversationListCellViewModel) -> UIContextualAction {
        let actionTitle = NSLocalizedString("Add Participant", comment: "Add memeber to conversation")
        let addMemeberAction = UIContextualAction(
            style: .normal,
            title: actionTitle,
            handler: { [self] (action, view, completionHandler) in
                guard !conversationCell.userInteractionState.isAddingParticipant else {
                    completionHandler(false)
                    return
                }
                self.showAddParticipantAlert(for: conversationCell)
            })

        return addMemeberAction
    }

    private func showAddParticipantAlert(for conversationCell: ConversationListCellViewModel) {
        let alert = UIAlertController(title: NSLocalizedString("Add participant", comment: "Add participant action"), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Identity", comment: "Users identity")
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Title for canceling current action"), style: .cancel, handler: { action in
            alert.removeFromParent()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: "Add someone to a conversation"), style: .default, handler: { action in
            guard let input = alert.textFields?.first, let id = input.text, id != "" else {
                return
            }
            self.conversationListViewModel.onAddParticipant(participantIdentity: id, conversationSid: conversationCell.sid)
        }))

        self.present(alert, animated: true)
    }

    func onLogout() {
        // TODO: remove notification registrations, delete info from user defaults
        let conversationListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window??.rootViewController = conversationListVC
        }
    }
}
