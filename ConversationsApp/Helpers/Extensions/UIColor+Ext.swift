//
//  UIColor+Ext.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 07.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit
import SwiftUI

extension UIColor {

    static let incomingMessageBackgroundColor = UIColor(named: "IncomingMessageBackgroundColor")!
    static let outgoingMessageBackgroundColor = UIColor(named: "OutgoingMessageBackgroundColor")!
    static let brandBackgroudColor = UIColor(named: "BrandBackgroundColor")!
    static let errorBackgroundColor = UIColor(named: "ErrorBackgroundColor")!
    static let primaryBackgroundColor = UIColor(named: "PrimaryBackgroundColor")!
    static let primaryDarkerBackgroundColor = UIColor(named: "PrimaryDarkerBackgroundColor")!
    static let primaryDarkestBackgroundColor = UIColor(named: "PrimaryDarkestBackgroundColor")!
    static let successBackgroundColor = UIColor(named: "SuccessBackgroundColor")!
    static let userBackgroundColor = UIColor(named: "UserBackgroundColor")!
    static let lightBackgroundColor = UIColor(named: "LightBackgroundColor")!

    static let errorButtonColor = UIColor(named: "ErrorButtonColor")!
    static let inverseButtonColor = UIColor(named: "InverseButtonColor")!
    static let primaryButtonColor = UIColor(named: "PrimaryButtonColor")!
    static let errorTappedButtonColor = UIColor(named: "ErrorTappedButtonColor")!
    static let primaryTappedButtonColor = UIColor(named: "PrimaryTappedButtonColor")!

    static let errorIconColor = UIColor(named: "ErrorIconColor")!
    static let inverseIconColor = UIColor(named: "InverseIconColor")!
    static let linkIconColor = UIColor(named: "LinkIconColor")!
    static let statusIconColor = UIColor(named: "StatusIconColor")!
    static let successIconColor = UIColor(named: "SuccessIconColor")!
    static let textIconColor = UIColor(named: "TextIconColor")!

    static let lightBorderColor = UIColor(named: "LightBorderColor")!

    static let errorTextColor = UIColor(named: "ErrorTextColor")!
    static let inverseTextColor = UIColor(named: "InverseTextColor")!
    static let lightLinkTextColor = UIColor(named: "LightLinkTextColor")!
    static let linkTextColor = UIColor(named: "LinkTextColor")!
    static let textColor = UIColor(named: "TextColor")!
    static let weakTextColor = UIColor(named: "WeakTextColor")!
}

extension Color {
    public static let incomingMessageBackgroundColor = Color(UIColor.incomingMessageBackgroundColor)
    public static let outgoingMessageBackgroundColor = Color(UIColor.outgoingMessageBackgroundColor)
    public static let textInverse = Color(UIColor.inverseTextColor)
    public static let textWeak = Color(UIColor.weakTextColor)
    public static let textInverseWeak = Color(UIColor.weakTextColor)
    public static let primaryBackgroundColor = Color(UIColor.primaryBackgroundColor)

    static let textColor = Color(UIColor.textColor)
}
