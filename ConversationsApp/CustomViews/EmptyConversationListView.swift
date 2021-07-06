//
//  EmptyConversationListView.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 22.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class EmptyConversationListView: UIView {

    var buttonAction: (() -> Void)? {
        didSet {
            button.action = buttonAction
        }
    }

    private let button = ConvoButton(type: .normal)

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
        backgroundColor = .systemBackground

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = NSLocalizedString("No Conversations", comment: "No Conversations title")
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = .textColor
        title.numberOfLines = 0
        title.sizeToFit()
        title.textAlignment = .center
        view.addSubview(title)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.topAnchor),
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = NSLocalizedString("Conversations you create or are involved in will appear here.",
                                          comment: "No Conversations subtitle")
        subtitle.font = .systemFont(ofSize: 16)
        subtitle.textColor = .weakTextColor
        subtitle.numberOfLines = 0
        subtitle.textAlignment = .center
        subtitle.sizeToFit()
        view.addSubview(subtitle)
        NSLayoutConstraint.activate([
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(lessThanOrEqualTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(lessThanOrEqualTo: subtitle.leadingAnchor, constant: 16),
            subtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        button.title = NSLocalizedString("Create new Conversation", comment: "Create new Conversation")
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
