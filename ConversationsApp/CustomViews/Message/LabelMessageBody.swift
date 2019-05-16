//
//  MessageBodyLabel.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class LabelMessageBody: UILabel {

    let insetSize: CGFloat = 4

    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    var error = false {
        didSet {
            if (error) {
                backgroundColor = UIColor(named: "MessageBackgroundError")
            } else {
                backgroundColor = UIColor(named: "MessageBackground")
            }
        }
    }

    required init?(coder: NSCoder) {
        textInsets = UIEdgeInsets(top: insetSize, left: insetSize, bottom: insetSize, right: insetSize)
        super.init(coder: coder)
        setup()
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = insetSize * 2
        backgroundColor = UIColor(named: "MessageBackground")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
