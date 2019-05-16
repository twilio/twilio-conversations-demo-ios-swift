//
//  ParticipantListVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ParticipantListVC: UIViewController {

    // MARK: Interface Builder outlets

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var participantsTableView: UITableView!

    // MARK: Properties

    var conversationSid: String = ""
    private lazy var participantListViewModel: ParticipantListViewModel = ParticipantListViewModel(conversationSid: conversationSid)
    var selectedParticipant: TCHParticipant?

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        participantsTableView.delegate = participantListViewModel
        participantsTableView.dataSource = participantListViewModel
        participantListViewModel.delegate = self
        searchBar.delegate = self
        addGestureRecognizers()
    }

    // MARK: GestureRecognizers

    func addGestureRecognizers() {
        navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @objc func endEditing() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showParticipantDetails", let detailsVC = segue.destination as? ParticipantDetailsVC {
            detailsVC.participantListViewModel = participantListViewModel
            detailsVC.participant = selectedParticipant
        }
    }
}

extension ParticipantListVC: ParticipantListViewModelListener {
    func onDisplayError(_ error: Error) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Error", comment: "Alert title message for occured error"), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledgment that this error message was read"), style: .default))
            self.present(ac, animated: true)
        }
    }

    func onParticipantsUpdated() {
        DispatchQueue.main.async {
            self.participantsTableView.reloadData()
        }
    }

    func onParticipantRemoved(_ participant: TCHParticipant) {
        DispatchQueue.main.async {
            self.participantListViewModel.filterParticipantsBy("")
            self.presentedViewController?.dismiss(animated: true)
        }
    }

    func onParticipantTap(_ participant: TCHParticipant) {
        DispatchQueue.main.async {
            self.selectedParticipant = participant
            self.performSegue(withIdentifier: "showParticipantDetails", sender: self)
        }
    }
}

extension ParticipantListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async {
            self.participantListViewModel.filterParticipantsBy(searchText)
        }
    }
}
