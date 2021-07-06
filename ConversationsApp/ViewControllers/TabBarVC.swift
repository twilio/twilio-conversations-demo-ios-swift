//
//  TabBarVC.swift
//  ConversationsApp
//
//  Created by Ilia Kolomeitsev on 21.07.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().unselectedItemTintColor = .inverseIconColor
        hidesBottomBarWhenPushed = true
    }
}
