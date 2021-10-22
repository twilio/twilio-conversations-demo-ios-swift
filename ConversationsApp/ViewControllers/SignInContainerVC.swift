//
//  SignInContainerVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class SignInContainerVC: UIViewController {

    private let transformB: CGFloat = 0.21255656167 // tan(12)
    private let container = UIView()
    private var centerContainerConstraint: NSLayoutConstraint!
    private var topViewConstraint: NSLayoutConstraint!

    private let statusView = StatusViewController.statusView
    private weak var embeddedView: UIView?
    var initialView: UIView?

    init(initialView: UIView?) {
        self.initialView = initialView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func embedViewInContainer(_ view: UIView) {
        initialView = nil
        embeddedView?.removeFromSuperview()

        embeddedView = view
        view.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 24),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        UIView.animate(withDuration: 0.25) {
            self.container.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        setUpBackgroud()
        hideKeyboardOnClickOutside()
        setUpViews()
        if let initialView = self.initialView {
            self.initialView = nil
            DispatchQueue.main.async {
                self.embedViewInContainer(initialView)
            }
        }
        container.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        topViewConstraint.constant = view.safeAreaInsets.top
    }

    private func setUpViews() {
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor.brandBackgroudColor
        view.addSubview(topView)
        topViewConstraint = topView.heightAnchor.constraint(equalToConstant: view.safeAreaInsets.top)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topViewConstraint,
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        view.addSubview(statusView)
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let convoLogoView = UIImageView(image: UIImage(named: "conversationsLogo")!)
        convoLogoView.tintColor = .inverseIconColor
        convoLogoView.translatesAutoresizingMaskIntoConstraints = false
        let topLogoConstraint = convoLogoView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 24)
        topLogoConstraint.priority = .defaultHigh
        view.addSubview(convoLogoView)
        NSLayoutConstraint.activate([
            topLogoConstraint,
            convoLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            convoLogoView.heightAnchor.constraint(equalToConstant: 42),
        ])

        let convoLabel = UILabel()
        convoLabel.text = NSLocalizedString("Twilio Conversations", comment: "Twilio Conversations sign in title")
        convoLabel.backgroundColor = .inverseTextColor
        convoLabel.translatesAutoresizingMaskIntoConstraints = false
        convoLabel.backgroundColor = .clear
        convoLabel.textColor = .inverseTextColor
        convoLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.addSubview(convoLabel)
        NSLayoutConstraint.activate([
            convoLabel.topAnchor.constraint(equalTo: convoLogoView.bottomAnchor),
            convoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            convoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10),
            convoLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: 10),
        ])

        let demoLabel = UILabel()
        demoLabel.text = NSLocalizedString("Demo experience", comment: "Demo expirience sign in subtitle")
        demoLabel.backgroundColor = .inverseTextColor
        demoLabel.translatesAutoresizingMaskIntoConstraints = false
        demoLabel.backgroundColor = .clear
        demoLabel.textColor = .weakerTextTextColor
        demoLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        view.addSubview(demoLabel)
        NSLayoutConstraint.activate([
            demoLabel.topAnchor.constraint(equalTo: convoLabel.bottomAnchor),
            demoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            demoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10),
            demoLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: 10),
        ])

        container.layer.cornerRadius = 8
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        centerContainerConstraint = container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerContainerConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(greaterThanOrEqualTo: demoLabel.bottomAnchor, constant: 40),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            centerContainerConstraint,
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
        ])

        let twilioLogo = UIImageView(image: UIImage(named: "twilioLogo")!)
        twilioLogo.tintColor = .inverseIconColor
        twilioLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(twilioLogo)
        NSLayoutConstraint.activate([
            twilioLogo.topAnchor.constraint(greaterThanOrEqualTo: container.bottomAnchor, constant: 40),
            twilioLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.bottomAnchor.constraint(equalTo: twilioLogo.bottomAnchor, constant: 32),
        ])

        view.bringSubviewToFront(statusView)
        view.bringSubviewToFront(topView)

        view.layoutIfNeeded()
    }

    private func setUpBackgroud() {
        let screenRect = self.view.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height

        self.view.layer.backgroundColor = UIColor.brandBackgroudColor.cgColor

        let subLayer = CALayer()
        subLayer.backgroundColor = UIColor.primaryDarkestBackgroundColor.cgColor
        subLayer.frame = .init(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight / 2)
        subLayer.allowsEdgeAntialiasing = true

        let transform = CGAffineTransform(a: 1, b: -transformB, c: 0, d: 1, tx: 0, ty: transformB * screenWidth / 2)

        subLayer.setAffineTransform(transform)

        self.view.layer.addSublayer(subLayer)
    }

    // MARK: - Move container view with keyboard

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            let maxY = container.frame.height / 2 + (view.frame.height / 2)
            centerContainerConstraint.constant = min(0, keyboardSize.minY - maxY - 16)

            centerContainerConstraint.priority = .required

            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

            centerContainerConstraint.constant = 0
            centerContainerConstraint.priority = .defaultLow

            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // MARK: - Hide keyboard

    func hideKeyboardOnClickOutside() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
