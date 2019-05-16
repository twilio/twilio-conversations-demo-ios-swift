//
//  ImagePreviewVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import UIKit

class ImagePreviewVC: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!

    var imageURL: URL?
    var mediaSid: String?

    override func viewDidLoad() {
        addShareButton()
        view.backgroundColor = .black
        guard let url = imageURL,
              let mediaSid = mediaSid else {
            return
        }

        mainImage.loadImage(mediaSid: mediaSid, at: url) { [weak self] error in
            if error != nil {
                let alert = UIAlertController(title: NSLocalizedString("Media could not be loaded ", comment: "Alert title for the load media error"),
                                              message: NSLocalizedString("We could not load the media", comment: "Error message for the load media error"),
                                              preferredStyle: .alert)
                self?.present(alert, animated: true)
            }
        }
    }

    func addShareButton() {
        let shareBar: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.action, target: self, action: #selector(self.shareImage))
        self.navigationItem.rightBarButtonItem = shareBar;
    }

    @objc
    func shareImage() {
        guard let mainImage = mainImage else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [mainImage] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

}
