//
//  ReactionListVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import UIKit

class ReactionListVC: UIViewController {

    @IBOutlet weak var reactionList: UITableView!

    var messageSid: String!
    var reactionType: String!
    var viewModel: ReactionListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = reactionType
        viewModel = ReactionListViewModel(messageSid: messageSid, reactionType: reactionType)
        reactionList.register(ParticipantListCell.self, forCellReuseIdentifier: "ParticipantList")
        reactionList.dataSource = viewModel
    }
}

extension ReactionListVC: ReactionListViewModelDelegate {
    func onDataUpdated() {
        reactionList.reloadData()
    }
}
