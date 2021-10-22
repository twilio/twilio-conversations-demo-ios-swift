//
//  ConvoButton.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 07.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

private class HighlightableButton: UIButton {

    var defaultBackgroundColor: UIColor?
    var highlightedColor: UIColor?

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedColor : defaultBackgroundColor
            layer.borderColor = currentTitleColor.cgColor
        }
    }
}

class ConvoButton: UIView {

    var title = "" {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    private let button = HighlightableButton()
    var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(type: .normal)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize(type: .normal)
    }

    init(type: Type) {
        super.init(frame: .zero)
        initialize(type: type)
    }

    func sendAction() {
        button.sendActions(for: .touchUpInside)
    }

    private func initialize(type: Type) {
        translatesAutoresizingMaskIntoConstraints = false

        button.defaultBackgroundColor = type.color
        button.highlightedColor = type.tappedColor

        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = type.color
        button.layer.cornerRadius = 4
        button.layer.allowsEdgeAntialiasing = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true

        button.setTitleColor(type.textColor, for: .normal)
        button.setTitleColor(type.tappedTextColor, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)

        button.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)

        if case .inverse = type {
            button.layer.borderWidth = 2
            button.layer.borderColor = type.textColor.cgColor
        }

        button.addTarget(self, action: #selector(onButtonTap), for: .touchUpInside)

        embed(view: button)
    }

    @objc func onButtonTap() {
        action?()
    }

    enum `Type` {
        case normal, error, inverse

        var color: UIColor {
            switch self {
            case .error:
                return .errorButtonColor
            case .normal:
                return .primaryButtonColor
            case .inverse:
                return .inverseButtonColor
            }
        }

        var textColor: UIColor {
            switch self {
            case .inverse:
                return .primaryButtonColor
            case .error, .normal:
                return .inverseTextColor
            }
        }

        var tappedTextColor: UIColor {
            switch self {
            case .error, .normal:
                return .inverseTextColor
            case .inverse:
                return .primaryTappedButtonColor
            }
        }

        var tappedColor: UIColor {
            switch self {
            case .inverse:
                return .inverseButtonColor
            case .normal:
                return .primaryTappedButtonColor
            case .error:
                return .errorTappedButtonColor
            }
        }
    }
}
