//
//  NavigationBar+Ext.swift
//  ConversationsApp
//
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

/// https://khorbushko.github.io/article/2020/11/24/navigation-bar.html
struct NavigationBarAppearanceColor: ViewModifier {
    init(backgroundColor: UIColor?, tintColor: UIColor) {
        let appearance = UINavigationBarAppearance()

        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = tintColor
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationBarWith(
        backgroundColor: UIColor?,
        tintColor: UIColor) -> some View
    {
        modifier(
            NavigationBarAppearanceColor(
                backgroundColor: backgroundColor,
                tintColor: tintColor
            )
        )
    }
}
