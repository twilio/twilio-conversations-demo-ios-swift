//
//  ConversationDetailsVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ConversationDetailsViewModel: NSObject {

    // MARK: Properties

    private let conversationSid: String
    private let conversationsRepository: ConversationsRepositoryProtocol
    private let conversationDetailsManager: ConversationDetailsManagerProtocol
    private(set) var observableConversation: ObservableFetchRequestResult<PersistentConversationDataItem>? {
        didSet {
            self.updateConversationActionsList()
            self.delegate?.onConversationUpdated()
        }
    }
    private(set) var actionsList: [ConversationDetailsActionCellViewModel] = []

    weak var delegate: ConversationDetailsViewModelListener?

    // MARK: Initialization

    init(conversationSid: String, ConversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared, detailsManager: ConversationDetailsManagerProtocol = ConversationDetailsManager()) {
        self.conversationSid = conversationSid
        self.conversationsRepository = ConversationsRepository
        self.conversationDetailsManager = detailsManager
        super.init()
        loadConversation()
        listenForConversationChanges()
    }

    // MARK: Deinitialization

    deinit {
        unsubscribeFromConversationChanges()
    }

    // MARK: Methods

    private func unsubscribeFromConversationChanges() {
        observableConversation?.removeObserver(self)
    }

    private func loadConversation() {
        observableConversation = fetchConversation(sid: conversationSid)
    }

    private func fetchConversation(sid: String) -> ObservableFetchRequestResult<PersistentConversationDataItem> {
        let conversation = conversationsRepository.getConversationWithSid(sid)

        conversation.requestStatus.observe(with: self) { [weak self] status in
            switch status {
            case .error(let error):
                self?.delegate?.onDisplayError(error)
            default:
                break
            }
        }

        return conversation.data
    }

    private func updateConversationActionsList() {
        guard let conversation = observableConversation?.value?.first else { return }
        let currentMuteStatus = TCHConversationNotificationLevel(rawValue: Int(conversation.notificationLevel))
        let muteActionTitle = currentMuteStatus == TCHConversationNotificationLevel.default ?
            NSLocalizedString("Mute", comment: "action for muting conversation"):
            NSLocalizedString("Unmute", comment: "action for unmuting conversation")

        actionsList = [
            ConversationDetailsActionCellViewModel(cellImage: UIImage(named: "add_participant")!, cellTitle: "Add Participant", action: .addParticipant),
            ConversationDetailsActionCellViewModel(cellImage: UIImage(named: "participants")!, cellTitle: "Participant List", segueToPerform: "goToParticipantList"),
            ConversationDetailsActionCellViewModel(cellImage: UIImage(named: "edit")!, cellTitle: "Rename Conversation", action: .renameConversation),
            ConversationDetailsActionCellViewModel(cellImage: UIImage(named: "mute")!, cellTitle: muteActionTitle, action: .muteConversation),
            ConversationDetailsActionCellViewModel(cellImage: UIImage(named: "delete")!, cellTitle: "Delete Conversation", action: .deleteConversation)
        ]
        self.delegate?.onActionsListUpdate()
    }

    private func listenForConversationChanges() {
        observableConversation?.observe(with: self) { [weak self] conversationItem in
            self?.delegate?.onConversationUpdated()
        }
    }

    func addParticipant(_ identity: String) {
        conversationDetailsManager.addParticipant(identity: identity, sid: self.conversationSid) { [weak self] (error) in
            if let error = error {
                self?.delegate?.onDisplayError(error)
            } else {
                self?.delegate?.onParticipantAdded(identity: identity)
            }
        }
    }

    func renameConversation(_ name: String) {
        conversationDetailsManager.setConversationFriendlyName(sid: self.conversationSid, friendlyName: name) { [weak self] (error) in
            if let error = error {
                self?.delegate?.onDisplayError(error)
            }
        }
    }

    func muteConversation() {
        guard let conversation = observableConversation?.value?.first else { return }
        let currentMuteLevel = TCHConversationNotificationLevel(rawValue: Int(conversation.notificationLevel))
        let newMuteLevel = currentMuteLevel == TCHConversationNotificationLevel.muted ? TCHConversationNotificationLevel.default : TCHConversationNotificationLevel.muted

        conversationDetailsManager.setConversationNotificationLevel(sid: self.conversationSid, level: newMuteLevel) { [weak self] (error) in
            if let error = error {
                self?.delegate?.onDisplayError(error)
            } else {
                self?.updateConversationActionsList()
            }
        }
    }

    func deleteConversation() {
        conversationDetailsManager.destroyConversation(sid: self.conversationSid) { [weak self] (error) in
            if let error = error {
                self?.delegate?.onDisplayError(error)
            }
        }
    }
}

extension ConversationDetailsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel: ConversationDetailsActionCellViewModel = actionsList[indexPath.row]
        let cell: ConversationDetailsActionCell = tableView.dequeueReusableCell(withIdentifier: "conversationDetailsActionCell") as! ConversationDetailsActionCell
        cell.setup(with: cellViewModel)
        return cell
    }
}
