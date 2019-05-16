//
//  SplashVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class SplashVC: UIViewController, SplashStateObserver {

    // MARK: Interface Builder outlets

    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!

    // MARK: Properties

    private let splashViewModel = SplashViewModel()
    private lazy var loadingView = LoadingView()

    // MARK: UIViewController

    override func viewDidLoad() {
        splashViewModel.splashStateObserver = self
        loadingView.embedInView(view)
        retryButton.isHidden = !self.splashViewModel.retryVisible
        signOutButton.isHidden = !self.splashViewModel.signOutVisible
        splashViewModel.signIn()
    }

    // MARK: Interface Builder actions

    @IBAction func retryPressed(_ sender: UIButton) {
        splashViewModel.signIn()
    }

    @IBAction func signOutPressed(_ sender: Any) {
        splashViewModel.signOut()
    }

    @IBAction func backToSignInPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: SplashStateObserver

    func onStatusChanged() {
        DispatchQueue.main.async {
            if self.splashViewModel.status == .connecting {
                self.statusText.text = "Connecting..."
                self.loadingView.startLoading()
            } else {
                self.statusText.text = ""
                self.loadingView.stopLoading()
            }
        }
    }

    func onRetryStateChanged() {
        DispatchQueue.main.async {
            self.retryButton.isHidden = !self.splashViewModel.retryVisible
        }
    }

    func onSignOutStateChanged() {
        DispatchQueue.main.async {
            self.signOutButton.isHidden = !self.splashViewModel.signOutVisible
        }
    }

    func onDisplayError(_ error: Error, onAcknowledged: (() -> Void)?) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Sign in error",
                                       comment: "Alert title message for occured error"),
                                       message: error.localizedDescription, preferredStyle: .alert)

            ac.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                       comment: "Acknowledgment that this error message was read"), style: .default,
                                       handler: { _ in
                                        onAcknowledged?()
            }))

            self.present(ac, animated: true)
        }
    }

    func onShowLoginScreen() {
        let conversationListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window??.rootViewController = conversationListVC
        }
    }

    func onShowConversationListScreen() {
        let conversationListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavController")
        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window??.rootViewController = conversationListVC
        }
    }
}
