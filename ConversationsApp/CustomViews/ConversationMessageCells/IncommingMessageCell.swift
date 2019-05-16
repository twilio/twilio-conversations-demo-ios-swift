//
//  IncommingMessageCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//
import UIKit

class IncommingMessageCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var messageReactionsView: UICollectionView!

    var messageViewModel: MessageDataListItem!
    private weak var delegate: MessageCellDelegate?

    func setup(with messageViewModel: MessageDataListItem, withDelegate delegate: MessageCellDelegate? = nil) {
        self.messageViewModel = messageViewModel
        bodyLabel.text = messageViewModel.body
        self.delegate = delegate
        messageReactionsView.register(ReactionCounterView.self, forCellWithReuseIdentifier: "reactionViewCell")
        messageReactionsView.dataSource = self
        messageReactionsView.delegate = self
        messageReactionsView.reloadData()
        self.contentView.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(onMessageLongTapped)))
    }

    @objc
    func onMessageLongTapped() {
        delegate?.onMessageLongPressed(messageViewModel)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.messageViewModel.reactions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reactionViewCell", for: indexPath) as! ReactionCounterView
        cell.reactionModel = self.messageViewModel.reactions[indexPath.row]
        cell.delegate = self
        return cell
    }

}

extension IncommingMessageCell: ReactionCounterViewDelegate {

    func onReactionTapped(reactionModel: ReactionViewModel) {
         delegate?.onReactionTapped(forMessage: self.messageViewModel, reactionModel: reactionModel)
    }
}
