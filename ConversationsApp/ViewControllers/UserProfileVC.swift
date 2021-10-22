//
//  UserProfileVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class UserProfileVC: UIViewController, UITextFieldDelegate, UserProfileViewModelListener {

    // MARK: Interface Builder outlets

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var identityTextView: UITextField!
    @IBOutlet weak var friendlyNameLabel: UILabel!
    @IBOutlet weak var friendlyNameTextView: UITextField!
    @IBOutlet weak var participantSinceTitleLabel: UILabel!
    @IBOutlet weak var participantSinceLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Properties

    private lazy var userProfileViewModel: UserProfileViewModel = UserProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizers()
        userProfileViewModel.delegate = self
        friendlyNameTextView.delegate = self

        identityLabel.text = NSLocalizedString("Identity", comment: "Title for user identity label")
        friendlyNameLabel.text = NSLocalizedString("Friendly Name", comment: "Title for user friendly name label")
        participantSinceTitleLabel.text = NSLocalizedString("Participant Since", comment: "Title for time since user is a participant")
        statusTitleLabel.text = NSLocalizedString("Status", comment: "Title for user online/offline status")

        identityTextView.text = userProfileViewModel.user?.identity ?? ""
        friendlyNameTextView.text = userProfileViewModel.user?.friendlyName ?? ""
    }

    // MARK: GestureRecognizers

    func addGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @objc func endEditing() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: UITextFieldDelegate

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let newName = textField.text, newName != userProfileViewModel.user?.friendlyName {
            userProfileViewModel.updateFriendlyName(newName)
            activityIndicator.startAnimating()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newName = textField.text, newName != userProfileViewModel.user?.friendlyName {
            userProfileViewModel.updateFriendlyName(newName)
            activityIndicator.startAnimating()
        }

        return true
    }

    // MARK: UserProfileViewModelListener

    func onFriendlyNameUpdated() {
        activityIndicator.stopAnimating()
        endEditing()
    }

    func onDisplayError(_ error: Error) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Error", comment: "Alert title message for occured error"), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledgment that this error message was read"), style: .default))

            self.activityIndicator.stopAnimating()
            self.present(ac, animated: true)
        }
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion:nil)
    }

    @IBAction func onSignOut(_ sender: Any) {
        // TODO: move it to appropriate place
        try? ConversationsCredentialStorage.shared.deleteCredentials()

        DispatchQueue.main.async {
            let controller = SignInController()
            UIView.transition(with: UIApplication.shared.delegate!.window!!, duration: 0.2, options: .transitionCrossDissolve) {
                UIApplication.shared.delegate?.window??.rootViewController = controller.signInContainerVC
            }

            StatusViewController.activateShortLived(text: "Signed out successfully", type: .success, animate: false)

            ConversationsClientWrapper.wrapper.shutdown()
        }
    }
}
