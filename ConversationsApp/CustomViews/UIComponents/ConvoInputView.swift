//
//  ConvoInputView.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 07.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class ConvoInputView: UIView {

    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let divider = UIView()

    lazy private var eyeIconButton = UIButton()

    private var textFieldToTitleLabelConstraint: NSLayoutConstraint!
    private var passwordVisibility = PasswordVisibility.hidden

    var inputState: InputState = .normal {
        didSet {
            switch inputState {
            case .normal:
                divider.backgroundColor = .lightBorderColor
            case .error:
                divider.backgroundColor = .errorBackgroundColor
            }
        }
    }

    var placeholder = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }

    var text: String? {
        return textField.text
    }

    var title: String? {
        didSet {
            titleLabel.text = title
            if let title = title, title.count > 0 {
                titleLabel.isHidden = false
                textFieldToTitleLabelConstraint.constant = 25
            } else {
                titleLabel.isHidden = true
                textFieldToTitleLabelConstraint.constant = 0
            }
        }
    }

    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }

    var autocapitalizationType: UITextAutocapitalizationType = .sentences {
        didSet {
            textField.autocapitalizationType = autocapitalizationType
        }
    }

    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }

    func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        textField.addTarget(target, action: action, for: event)
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(type: .text)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize(type: .text)
    }

    init(type: Type) {
        super.init(frame: .zero)
        initialize(type: type)
    }

    private func initialize(type: Type) {
        translatesAutoresizingMaskIntoConstraints = false

        addTapGesture()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .weakTextColor
        titleLabel.text = nil
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.sizeToFit()
        titleLabel.isHidden = true
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 18),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 17),
        ])

        textField.backgroundColor = .white
        textField.textColor = .textColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 16)
        addSubview(textField)
        textFieldToTitleLabelConstraint = textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        NSLayoutConstraint.activate([
            textFieldToTitleLabelConstraint,
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 18),
        ])

        divider.backgroundColor = .lightBorderColor
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -2),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if case .password = type {
            eyeIconButton.addTarget(self, action: #selector(onToggleVisibility), for: .touchUpInside)
            eyeIconButton.translatesAutoresizingMaskIntoConstraints = false
            eyeIconButton.tintColor = .primaryButtonColor
            addSubview(eyeIconButton)
            NSLayoutConstraint.activate([
                eyeIconButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
                eyeIconButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            ])
            updatePasswordField()
        } else {
            textField.clearButtonMode = .whileEditing
        }
    }

    private func updatePasswordField() {
        textField.isSecureTextEntry = passwordVisibility.isSecure
        eyeIconButton.setImage(passwordVisibility.image, for: .normal)
    }

    @objc func onToggleVisibility() {
        passwordVisibility.toggle()
        updatePasswordField()
    }

    enum `Type` {
        case text, password
    }

    enum InputState {
        case normal, error
    }

    private enum PasswordVisibility {
        case visible, hidden

        var image: UIImage {
            switch self {
            case .hidden:
                return UIImage(systemName: "eye")!
            case .visible:
                return UIImage(systemName: "eye.slash")!
            }
        }

        var isSecure: Bool {
            switch self {
            case .hidden:
                return true
            default:
                return false
            }
        }

        mutating func toggle() {
            switch self {
            case .hidden:
                self = .visible
            case .visible:
                self = .hidden
            }
        }
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - Tag gesture
    private func addTapGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShowKeyboard)))
    }

    @objc func onShowKeyboard() {
        textField.becomeFirstResponder()
    }
}
