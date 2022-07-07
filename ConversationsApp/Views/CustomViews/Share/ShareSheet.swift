//
//  ShareSheet.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/16/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

/// Abstract:
///     ShareSheet is a UIActivityViewController wrapped to be used on a SwiftUI view.
///
/// Usage:
///     On initialization provide the items you want to be available for sharing.
///     ActivityItems needs to be UIKit types, not  SwiftUI. For example, an Image type from SwiftUI won't work properly, use an UIImage instead.
///
struct ShareSheet: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIActivityViewController
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
}
