//
//  LoginVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, LoginStateObserver {
    
    // MARK: Interface Builder outlets
    
    @IBOutlet weak var usernameField: ConversationsDemoLoginTextField!
    @IBOutlet weak var passwordField: ConversationsDemoLoginTextField!
    @IBOutlet weak var loginForm: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorMesageLabel: UILabel!

    // MARK: Properties
    
    private let loginViewModel = LoginViewModel()
    private lazy var loadingView = LoadingView()
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        loginViewModel.loginStateObserver = self
        loadingView.embedInView(view)
        addGestureRecognizers()
        addKeyboardNotifications()
    }

    // MARK: Interface Builder actions
    
    @IBAction func signInPressed(_ sender: Any) {
        errorMesageLabel.isHidden = true
        guard
            let suppliedIdentity = usernameField.text,
            let suppliedPassword = passwordField.text
            else { return }
        loginViewModel.signIn(identity: suppliedIdentity, password: suppliedPassword)
    }
    
    // MARK: LoginStateObserver
    
    func onLoadingStateChanged() {
        if loginViewModel.isLoading {
            startLoading()
        } else {
            stopLoading()
        }
    }

    func showExpiredSession() {
        errorMesageLabel.isHidden = false
    }

    func onSignInSucceeded() {
        goToConversationListScreen()
    }
    
    func onSignInFailed(error: Error) {
        displayError(error)
    }
    
    // MARK: UI
    
    private func startLoading() {
        DispatchQueue.main.async {
            self.loadingView.startLoading()
        }
    }
    
    private func stopLoading() {
        DispatchQueue.main.async {
            self.loadingView.stopLoading()
        }
    }
    
    private func goToConversationListScreen() {
        let conversationListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavController")
        DispatchQueue.main.async {
            UIApplication.shared.delegate?.window??.rootViewController = conversationListVC
        }
    }
    
    private func displayError(_ error: Error) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Sign in error", comment: "Alert title message for occured error"), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledgment that this error message was read"), style: .default))
            self.present(ac, animated: true)
        }
    }

    // MARK: GestureRecognizers

    func addGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @objc func endEditing() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: Notifications

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        // Getting keyboard dimensions
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        // Adding additional scroll area
        scrollView.contentInset.bottom = keyboardFrame.height

        // Setting login form above the keyboard
        let distanceToBottom = view.frame.size.height - (loginForm.frame.origin.y) - (loginForm.frame.size.height)
        let collapseSpace = keyboardFrame.height - distanceToBottom

        guard collapseSpace > 0  else {
            return
        }

        scrollView.contentOffset = CGPoint(x: 0, y: collapseSpace + 10)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // Removing added addition scroll area
        scrollView.contentInset.bottom = 0
    }
}
