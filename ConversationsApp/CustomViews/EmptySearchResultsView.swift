//
//  EmptySearchResultView.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 26.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class EmptySearchResultsView: UIView {

    private let resultFormat = NSLocalizedString("No Conversation results for '%@'", comment: "No conversation results format string")
    private let label = UILabel()

    var searchQuery = "" {
        didSet {
            label.text = String(format: resultFormat, searchQuery)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    func initialize() {
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .systemBackground

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .weakTextColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16),
        ])
    }
}
