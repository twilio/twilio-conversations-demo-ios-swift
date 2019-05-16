//
//  ReactionViewModel.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ReactionListViewModelDelegate: AnyObject {
    func onDataUpdated()
}

class ReactionListViewModel: NSObject {
    weak var delegte: ReactionListViewModelDelegate?

    let reactionDAO: ReactionDAO
    let reactionType: String
    let messageSid: String
    var participants: [ParticipantDataItem] = []

    init(reactionDAO: ReactionDAO = ReactionDAOImpl(), messageSid: String, reactionType: String) {
        self.reactionDAO = reactionDAO
        self.reactionType = reactionType
        self.messageSid =  messageSid
        super.init()
        loadAndObserveReaction()
    }

    func loadAndObserveReaction() {
        guard let reactionType = ReactionType(rawValue: reactionType) else {
            fatalError("Received unexpected string as reaction type")
        }
        let observable = reactionDAO.getReactions(onMessage: messageSid, withType: reactionType)
        observable.observe(with: self) { [weak self] reactionArray in
            guard let reactions = reactionArray else {
                return
            }
            self?.participants = reactions
                .compactMap { $0.participant }
                .compactMap { $0.getParticipantDataItem()}
            self?.delegte?.onDataUpdated()
        }

    }
}

extension ReactionListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.participants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "participantListTableViewCell") as! ParticipantListCell
        cell.setup(with: participants[indexPath.row])
        return cell
    }
}
