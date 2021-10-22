//
//  ConvoSearchBar.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 25.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

private extension UIView {

    func findSubview(of aClass: AnyClass) -> UIView? {
        var iterateThrough: [UIView] = subviews
        while iterateThrough.count > 0 {
            let subview = iterateThrough.popLast()!
            if subview.isKind(of: aClass) {
                return subview
            }
            iterateThrough.append(contentsOf: subview.subviews)
        }
        return nil
    }
}

class ConvoSearchBar: UISearchBar {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    func initialize() {
        // Find a UITextField and change some properties in it
        if let searchTextField = findSubview(of: UITextField.self) as? UITextField {
            searchTextField.backgroundColor = .brandBackgroudColor
            searchTextField.textColor = .inverseTextColor
            searchTextField.tintColor = .inverseIconColor
            searchTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search for a Conversation...",
                                                                                                 comment: "Search for a conversation placeholder"),
                                                                       attributes: [.foregroundColor: UIColor.lightLinkTextColor])
            searchTextField.leftView?.tintColor = .inverseIconColor
            searchTextField.rightView?.tintColor = .inverseIconColor
        }

        tintColor = .inverseTextColor

        // Set clear image to be properly tinted
        setImage(UIImage(systemName: "xmark.circle.fill"), for: .clear, state: .normal)
    }
}

