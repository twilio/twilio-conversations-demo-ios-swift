//
//  StatusView.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 08.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class StatusViewController {

    static let statusView: UIView = StatusView()
    private static let viewTtl: TimeInterval = 1.2

    static func activate(text: String, type: Type, animate: Bool = true) {
        statusView.layoutIfNeeded()

        let updateView = {
            let statusView = self.statusView as! StatusView
            statusView.backgroundColor = type.backgroundColor
            statusView.imageView.tintColor = type.iconColor
            statusView.imageView.image = type.icon
            statusView.label.textColor = type.textColor
            statusView.label.font = type.textFont
            statusView.label.text = text
            statusView.heightConstraint.constant = 32
        }

        if animate {
            UIView.animate(withDuration: 0.25) {
                updateView()
                statusView.layoutIfNeeded()
                statusView.superview?.layoutIfNeeded()
            }
        } else {
            updateView()
        }
    }

    static func activateShortLived(text: String, type: Type, animate: Bool = true) {
        activate(text: text, type: type, animate: animate)
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.viewTtl) {
            deactivate()
        }
    }

    static func deactivate() {
        statusView.layoutIfNeeded()

        UIView.animate(withDuration: 0.25) {
            let statusView = self.statusView as! StatusView
            statusView.backgroundColor = .clear
            statusView.imageView.tintColor = .clear
            statusView.imageView.image = nil
            statusView.label.textColor = .clear
            statusView.label.text = nil
            statusView.heightConstraint.constant = 0
            statusView.layoutIfNeeded()
            statusView.superview?.layoutIfNeeded()
        }
    }

    enum `Type` {
        case error, success

        fileprivate var textFont: UIFont {
            switch self {
            case .success:
                return UIFont.systemFont(ofSize: 14, weight: .medium)
            case .error:
                return UIFont.systemFont(ofSize: 14, weight: .bold)
            }
        }

        fileprivate var iconColor: UIColor {
            switch self {
            case .success:
                return UIColor.successIconColor
            case .error:
                return UIColor.inverseIconColor
            }
        }

        fileprivate var backgroundColor: UIColor {
            switch self {
            case .success:
                return UIColor.successBackgroundColor
            case .error:
                return UIColor.errorBackgroundColor
            }
        }

        fileprivate var textColor: UIColor {
            switch self {
            case .success:
                return UIColor.textColor
            case .error:
                return UIColor.inverseTextColor
            }
        }

        fileprivate var icon: UIImage {
            switch self {
            case .success:
                return UIImage(systemName: "checkmark.circle.fill")!
            case .error:
                return UIImage(systemName: "exclamationmark.square.fill")!
            }
        }
    }
}

fileprivate class StatusView: UIView {

    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate var label: UILabel!
    fileprivate var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            view.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor),
        ])

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor),
        ])
    }
}
