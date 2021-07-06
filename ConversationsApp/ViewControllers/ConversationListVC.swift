//
//  ConversationListVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class ConversationListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ConversationListObserver, UISearchBarDelegate {

    // MARK: Interface Builder outlets

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchBar: ConvoSearchBar!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!

    var containerView = UIView()

    // MARK: Properties

    private let conversationListViewModel = ConversationListViewModel()
    private lazy var refreshControl = UIRefreshControl()

    private lazy var emptyStateView = EmptyConversationListView()
    private lazy var loadingStateView = LoadingConversationsView()
    private lazy var emptySearchResultsView = EmptySearchResultsView()

    // MARK: UIViewController

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(requestRefreshConversationList), for: .valueChanged)

        conversationListViewModel.delegate = self

        searchBar.delegate = self
        searchBarHeightConstraint.constant = 0

        setupContainerView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onNotificationTap()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
            let navigationController = self.navigationController,
            let conversation = conversationListViewModel.getConversationCellViewModel(by: conversationSid)
        else {
            fatalError("could not instantiate the ChannleVC UIViewController")
        }

        conversationVC.conversationSid = conversationSid
        conversationVC.setConversationViewModel(conversation.conversationViewModel)
        DispatchQueue.main.async {
            navigationController.pushViewController(conversationVC, animated: true)
        }
    }

    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        containerView.isHidden = true
    }

    private func showContainerView(with view: UIView) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.embed(view: view)
        containerView.isHidden = false
    }

    // MARK: UISearchBarDelegate

    @IBAction func onSearchButtonClicked(_ sender: Any) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.searchBarHeightConstraint.constant = 51
            self.searchBar.becomeFirstResponder()
            self.view.layoutIfNeeded()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        conversationListViewModel.searchQuery = searchBar.text
        emptySearchResultsView.searchQuery = searchBar.text ?? ""
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.searchBarHeightConstraint.constant = 0
            searchBar.resignFirstResponder()
            self.view.layoutIfNeeded()
        }
    }

    // MARK: Selector handles

    @objc func requestRefreshConversationList(refreshControl: UIRefreshControl) {
        conversationListViewModel.reloadConversationList()
        refreshControl.endRefreshing()
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversationListViewModel.isConversationListLoading {
            showContainerView(with: loadingStateView)
            return 0
        }

        if conversationListViewModel.presentedConversations.count == 0 {
            if conversationListViewModel.isSearchQueryActive {
                showContainerView(with: emptySearchResultsView)
            } else {
                showContainerView(with: emptyStateView)
            }
            return 0
        }

        UIView.animate(withDuration: 0.2) {
            self.containerView.isHidden = true
        }
        return conversationListViewModel.presentedConversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard conversationListViewModel.presentedConversations.count > 0,
              let conversationCellViewModel = conversationListViewModel.getConversationCellViewModel(at: indexPath.row) else {
            return UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell") as! ConversationListCell
        cell.setup(with: conversationCellViewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedConversation = self.conversationListViewModel.getConversationCellViewModel(at: indexPath.row)!
        navigateToConversation(selectedConversation.sid)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedConversation = conversationListViewModel.getConversationCellViewModel(at: indexPath.row)!

        let configuration = UISwipeActionsConfiguration(
            actions: [
                createLeaveConversationAction(for: selectedConversation),
                createNotificationLevelAction(for: selectedConversation),
            ])
        return configuration
    }

    private func createLeaveConversationAction(for conversationCell: ConversationListCellViewModel) -> UIContextualAction {
        let leaveAction = UIContextualAction(
            style: .destructive,
            title: NSLocalizedString("Leave", comment: "Action for leaving conversation"),
            handler: { _, _, completionHandler in
                guard !conversationCell.userInteractionState.isLeavingConversation else {
                    completionHandler(false)
                    return
                }
                let ac = UIAlertController(title: NSLocalizedString("Leave Conversation?",
                                                                    comment: "Leave conversation title"),
                                           message: NSLocalizedString("By leaving the Conversation you will no longer have access to participants or Conversation history.",
                                                                      comment: "Leave conversation description"),
                                           preferredStyle: .alert)
                ac.addAction(
                    UIAlertAction(title: NSLocalizedString("Cancel",
                                                           comment: "Acknowledgment that this error message was read"),
                                  style: .default,
                                  handler: { _ in
                                    completionHandler(false)
                                  }))
                ac.addAction(
                    UIAlertAction(title: NSLocalizedString("Leave",
                                                           comment: "Button title to leave conversation"),
                                  style: .destructive,
                                  handler: { action in
                                    self.conversationListViewModel.onLeaveConversation(sid: conversationCell.sid)
                                    completionHandler(true)
                                  }))
                self.present(ac, animated: true)
            })
        leaveAction.backgroundColor = .errorBackgroundColor
        return leaveAction
    }

    private func createNotificationLevelAction(for conversationCell: ConversationListCellViewModel) -> UIContextualAction {
        let notificationTitle = conversationCell.notificationLevel == .default ?
            NSLocalizedString("Mute", comment: "Action for muting conversation"):
            NSLocalizedString("Unmute", comment: "Action for unmuting conversation")

        let notificationLevelAction = UIContextualAction(
            style: .normal,
            title:  notificationTitle,
            handler: { _, _, completionHandler in
                guard !conversationCell.userInteractionState.isChangingNotificationLevel else {
                    completionHandler(false)
                    return
                }
                self.conversationListViewModel.onSetConversationNotificationLevel(
                    sid: conversationCell.sid,
                    level: conversationCell.notificationLevel == .default
                        ? .muted
                        : .default)
                completionHandler(true)
            }
        )
        notificationLevelAction.backgroundColor = .primaryBackgroundColor
        return notificationLevelAction
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newConvoVC = segue.destination as? NewConversationVC {
            newConvoVC.conversationListViewModel = conversationListViewModel
        }
    }
}
