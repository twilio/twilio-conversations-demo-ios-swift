//
//  KeyboardAware.swift
//  ConversationsApp
//
// Provide a .keyboardAware() view modifier for adjust view with the keyboard frame.
//
// https://github.com/ralfebert/KeyboardAwareSwiftUI/blob/master/Sources/KeyboardAware/KeyboardAware.swift
// Author: Ralf Ebert
// License: MIT
//

import SwiftUI

struct KeyboardAware: ViewModifier {
    @ObservedObject private var keyboard = KeyboardInfo.shared

    func body(content: Content) -> some View {
        content
            .padding(.bottom, self.keyboard.height)
            .edgesIgnoringSafeArea(self.keyboard.height > 0 ? .bottom : [])
    }
}

extension View {
    public func keyboardAware() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAware())
    }
}
