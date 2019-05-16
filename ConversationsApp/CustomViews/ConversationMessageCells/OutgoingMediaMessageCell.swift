//
//  OutgoingMediaMessageCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class OutgoingMediaMessageCell: UITableViewCell {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var uploadProgressLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!

    var delegate: OutgoingMessageDelegate?
    var messageViewModel: MessageDataListItem!

    func setup(with messageViewModel: MessageDataListItem, withDelegate  delegate: OutgoingMessageDelegate? = nil) {
        self.messageViewModel = messageViewModel
        loadingIndicator.isHidden = true
        retryButton.isHidden =  true
        uploadProgressLabel.isHidden = true
        self.delegate = delegate
        
        switch messageViewModel.mediaStatus {
        case .error:
            loadingIndicator.isHidden = true
            retryButton.isHidden = false
            uploadProgressLabel.isHidden = true
        case .uploading:
            loadingIndicator.isHidden = true
            guard let mediaProperties = messageViewModel.mediaProperties else {
                retryButton.isHidden = false
                return
            }
            uploadProgressLabel.isHidden = false
            print("[OutgoingMediaMessageCell] uploadging status update \(mediaProperties.percentage)%")
            uploadProgressLabel.text = "\(mediaProperties.percentage) %"
        case .downloading:
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            uploadProgressLabel.isHidden = true
        case .downloaded, .uploaded:
            loadingIndicator.isHidden = true
            guard let mediaSid = messageViewModel.mediaSid,
                  let properties = messageViewModel.mediaProperties,
                  let mediaURL = properties.url else {
                retryButton.isHidden = false
                return
            }
            mediaImageView.loadImage(mediaSid: mediaSid, at: mediaURL) { [weak self] error in
                if error != nil {
                    print("[Error] Media message with sid \(mediaSid) could not load message at URL \(mediaURL)")
                    self?.retryButton.isHidden = false
                    return
                }
                self?.addImageTappedAction()
            }
        case .none:
            NSLog("Received message dowload status with none status")
            break
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaImageView.alpha = 1
        mediaImageView.image = nil
        mediaImageView.cancelImageLoad()
        loadingIndicator.stopAnimating()
    }


    @IBAction func resendTapped(_ sender: Any) {
        if messageViewModel.sendStatus == .error {
            delegate?.onRetryToSendMediaMessage(messageViewModel)
        } else {
            delegate?.onRetryToDownloadMediaMessage(messageViewModel)
        }
    }

    func addImageTappedAction() {
        NSLog("[OutgoingMediaMessageCell] -> addImageTappedAction")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        mediaImageView.addGestureRecognizer(tapGestureRecognizer)
        mediaImageView.isUserInteractionEnabled = true
    }

    @objc
    func imageTapped() {
        delegate?.onImageTapped(message: self.messageViewModel)
    }
}
