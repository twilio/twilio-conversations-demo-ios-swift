//
//  ConversationsDemoLoginTextField.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

@IBDesignable
class ConversationsDemoLoginTextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 16
    @IBInspectable var insetY: CGFloat = 16
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
