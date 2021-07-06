//
//  CredentialsInput.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 08.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class CredentialsInput: UIView {

    typealias ButtonAction = (String?, String?) -> Void

    var onButtonTap: ButtonAction? {
        didSet {
            button.action = { [weak self] in
                self?.onButtonTap?(self?.textInput.text, self?.passwordInput.text)
            }
        }
    }

    private var passwordInput: ConvoInputView!
    private var textInput: ConvoInputView!
    private var button: ConvoButton!
    private var errorLabel: UILabel!
    private var heightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    func setError(text: String) {
        passwordInput.inputState = .error
        textInput.inputState = .error
        errorLabel.text = text
        UIView.animate(withDuration: 0.25) {
            self.heightConstraint.constant = 36
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }

    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false

        textInput = ConvoInputView(type: .text)
        textInput.placeholder = NSLocalizedString("Username", comment: "Username placeholder")
        textInput.autocapitalizationType = .none
        textInput.returnKeyType = .next
        addSubview(textInput)
        NSLayoutConstraint.activate([
            textInput.topAnchor.constraint(equalTo: topAnchor),
            textInput.leadingAnchor.constraint(equalTo: leadingAnchor),
            textInput.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        passwordInput = ConvoInputView(type: .password)
        passwordInput.placeholder = NSLocalizedString("Password", comment: "Password placeholder")
        passwordInput.autocapitalizationType = .none
        passwordInput.returnKeyType = .send
        addSubview(passwordInput)
        NSLayoutConstraint.activate([
            passwordInput.topAnchor.constraint(equalTo: textInput.bottomAnchor),
            passwordInput.leadingAnchor.constraint(equalTo: leadingAnchor),
            passwordInput.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.textColor = .errorTextColor
        errorLabel.numberOfLines = 0
        addSubview(errorLabel)
        heightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: errorLabel.trailingAnchor, constant: 16),
            errorLabel.topAnchor.constraint(equalTo: passwordInput.bottomAnchor),
            heightConstraint,
        ])

        button = ConvoButton(type: .normal)
        button.title = NSLocalizedString("Sign In", comment: "Sign in button")
        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32),
            bottomAnchor.constraint(equalTo: button.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 16),
        ])

        textInput.addTarget(passwordInput, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        passwordInput.addTarget(self, action: #selector(activateButton), for: .editingDidEndOnExit)
    }

    @objc func activateButton() {
        button.sendAction()
    }
}
