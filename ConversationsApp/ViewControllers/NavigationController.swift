//
//  NavigationController.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 09.09.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
