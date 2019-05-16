//
//  ParticipantListViewModel.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ParticipantListViewModel: NSObject {

    // MARK: Properties

    private let conversationSid: String
    private let conversationsRepository: ConversationsRepositoryProtocol
    private let participantListManager: ParticipantListManagerProtocol
    private var orderedParticipantFirstLetterList: [String] = []
    private(set) var observableConversation: ObservableFetchRequestResult<PersistentConversationDataItem>?
    private(set) var orderedParticipantList: [String: [ParticipantListCellViewModel]] = [:] {
        didSet {
            self.delegate?.onParticipantsUpdated()
        }
    }

    weak var delegate: ParticipantListViewModelListener?
    private var participantsFilter = ""

    // MARK: Init

    init(conversationSid: String, ConversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared, participantListManager: ParticipantListManagerProtocol = ParticipantListManager()) {
        self.conversationSid = conversationSid
        self.conversationsRepository = ConversationsRepository
        self.participantListManager = participantListManager
        super.init()
        self.getParticipants()
    }

    // MARK: Methods

    private func processParticipants(_ participants: [TCHParticipant]) {
        var sortedParticipants = participants.sorted { $0.identity! < $1.identity! }
        if participantsFilter != "" {
            sortedParticipants = sortedParticipants.filter { $0.identity != nil && $0.identity!.lowercased().contains(self.participantsFilter.lowercased()) }
        }
        sortedParticipants.forEach({ (participant) in
            guard let identity = participant.identity, let firstChar = identity.first else { return }
            let firstLetter = String(firstChar.lowercased())
            if !self.orderedParticipantFirstLetterList.contains(firstLetter) {
                self.orderedParticipantFirstLetterList.append(firstLetter)
                self.orderedParticipantList[firstLetter] = []
            }
            self.orderedParticipantList[firstLetter]!.append(ParticipantListCellViewModel(cellTitle: identity, participant: participant))
        })
    }

    func getParticipants(_ filterBy: String = "") {
        participantsFilter = filterBy
        participantListManager.getParticipants(conversationSid: conversationSid) { result in
            switch result {
            case .success(let participants):
                self.processParticipants(participants)
            case .failure(let error):
                self.delegate?.onDisplayError(error)
            }
        }
    }

    func filterParticipantsBy(_ title: String) {
        self.getParticipants(title)
    }

    func remove(participant: TCHParticipant) {
        participantListManager.remove(participant: participant, fromConversationWith: conversationSid) { [weak self] error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.delegate?.onDisplayError(error)
                return
            }
            self.delegate?.onParticipantRemoved(participant)
            self.delegate?.onParticipantsUpdated()
        }
    }
}

extension ParticipantListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? ParticipantListCell, let participant = cell.participant {
            delegate?.onParticipantTap(participant)
        }
    }
}

extension ParticipantListViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderedParticipantFirstLetterList.count
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return orderedParticipantFirstLetterList
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return orderedParticipantFirstLetterList[section].uppercased()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = orderedParticipantFirstLetterList[section]
        return orderedParticipantList[currentSection]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionKey = orderedParticipantFirstLetterList[indexPath.section]
        let cellViewModel: ParticipantListCellViewModel = orderedParticipantList[sectionKey]![indexPath.row]
        let cell: ParticipantListCell = tableView.dequeueReusableCell(withIdentifier: "participantListTableViewCell") as! ParticipantListCell
        cell.setup(with: cellViewModel)
        return cell
    }
}
