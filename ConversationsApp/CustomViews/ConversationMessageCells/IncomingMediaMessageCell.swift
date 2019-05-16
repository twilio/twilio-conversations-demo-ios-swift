//
//  IncomingMediaMessageCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class IncomingMediaMessageCell: UITableViewCell {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var loadingIndicartor: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!

    var contentImage: UIImage?
    weak var messageDelegate: MessageCellDelegate?
    private var messageViewModel: MessageDataListItem!

    func setup(with messageViewModel: MessageDataListItem,
               withDelegate  delegate: MessageCellDelegate? = nil) {
        self.messageViewModel = messageViewModel
        selectionStyle = .none
        retryButton.isHidden = true
        messageDelegate = delegate
        switch  messageViewModel.mediaStatus {
        case .downloading:
            retryButton.isHidden = true
            loadingIndicartor.isHidden = false
            loadingIndicartor.startAnimating()
        case .downloaded:
            handleMessageDownloaded()
        case .error:
            retryButton.isHidden = false
        case .none, .uploading, .uploaded:
            break
        }
    }

    @objc
    func imageTapped() {
        NSLog("Incoming message got tapped")
        messageDelegate?.onImageTapped(message: messageViewModel)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaImageView.image = nil
        mediaImageView.cancelImageLoad()
    }

    @IBAction func onRetryTapped(_ sender: Any) {
        messageDelegate?.onRetryToDownloadMediaMessage(messageViewModel)
    }

    func addImageTappedAction() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        mediaImageView.addGestureRecognizer(tapGestureRecognizer)
        mediaImageView.isUserInteractionEnabled = true
    }

    private func handleMessageDownloaded() {
        NSLog("[MediaMessage] Handling message downloaded with properties \(messageViewModel.mediaProperties.debugDescription)")
        guard let mediaProperties = messageViewModel.mediaProperties,
              let imageURL = mediaProperties.url,
              let mediaSid = messageViewModel.mediaSid else {
            retryButton.isHidden = false
            return
        }
        retryButton.isHidden = true
        loadingIndicartor.isHidden = true
        loadingIndicartor.stopAnimating()
        mediaImageView.loadImage(mediaSid: mediaSid, at: imageURL) { [weak self] error in
            self?.loadingIndicartor.stopAnimating()
            if error != nil {
                self?.retryButton.isHidden = false
                return
            }
            self?.addImageTappedAction()
        }
    }
}
