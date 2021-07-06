//
//  LoadingConversationsView.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 23.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class LoadingConversationsView: UIView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    func initialize() {
        translatesAutoresizingMaskIntoConstraints = true
        backgroundColor = .systemBackground

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let indicatorView = UIActivityIndicatorView(style: .medium)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.startAnimating()
        view.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            indicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Loading", comment: "Loading label")
        label.font = .systemFont(ofSize: 14)
        label.textColor = .weakTextColor
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
