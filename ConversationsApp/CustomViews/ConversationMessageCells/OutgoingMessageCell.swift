//
//  OutgoingMessageCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

protocol OutgoingMessageDelegate: MessageCellDelegate {

    func onRetryPressedForMessageItem(_ item: MessageDataListItem)
}

class OutgoingMessageCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var body: LabelMessageBody!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var messageReactionsView: UICollectionView!
    
    private weak var delegate: OutgoingMessageDelegate?
    private var messageViewModel: MessageDataListItem!
    
    func setup(with messageViewModel: MessageDataListItem,
               withDelegate  delegate: OutgoingMessageDelegate? = nil) {
        messageReactionsView.register(ReactionCounterView.self, forCellWithReuseIdentifier: "reactionViewCell")
        self.messageViewModel = messageViewModel
        body.text = messageViewModel.body
        selectionStyle = .none
        
        if (messageViewModel.sendStatus == .error) {
            retryButton.isHidden = false
            body.error = true
        } else {
            body.error = false
            retryButton.isHidden = true
        }
        self.delegate = delegate
        body.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(onMessageLongTapped)))
        messageReactionsView.dataSource = self
        messageReactionsView.delegate = self
        messageReactionsView.reloadData()
    }
    
    @objc
    private func onMessageLongTapped() {
        delegate?.onMessageLongPressed(messageViewModel)
    }
    
    @IBAction func onRetryPressed(_ item: Any) {
        delegate?.onRetryPressedForMessageItem(messageViewModel)
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

extension OutgoingMessageCell: ReactionCounterViewDelegate {

    func onReactionTapped(reactionModel: ReactionViewModel) {
        delegate?.onReactionTapped(forMessage: self.messageViewModel, reactionModel: reactionModel)
    }
}
