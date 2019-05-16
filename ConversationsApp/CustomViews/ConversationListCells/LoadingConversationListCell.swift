//
//  LoadingConversationListCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class LoadingConversationListCell: UITableViewCell {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    func startLoading() {
        loadingIndicator.startAnimating()
    }
}
