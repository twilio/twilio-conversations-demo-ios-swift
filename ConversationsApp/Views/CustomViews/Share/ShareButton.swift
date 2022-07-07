//
//  ShareButton.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/16/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

/// Abstract:
///     ShareButton is a button with a 'share' icon and displays a native share sheet when tapped.
///
/// Usage:
///     On initialization provide the items you want to be available for sharing.
///     
///     ItemsToShare needs to be UIKit types, not  SwiftUI. For example, an Image type from SwiftUI won't work properly, use an UIImage instead.
///
struct ShareButton: View {
    
    var itemsToShare: [Any]
    @State private var showShareSheet = false
    
    var body: some View {
        Button(action: { showShareSheet.toggle() }) {
            Image(systemName: "square.and.arrow.up")
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }.sheet(isPresented: self.$showShareSheet) {
            ShareSheet(activityItems: itemsToShare)
        }.padding()
    }
}

struct TestSheetViewProvider_Previews: PreviewProvider {
    private static var image = UIImage(named: "twilioLogo")
    
    static var previews: some View {
        ShareButton(itemsToShare: [image!])
            .previewLayout(.fixed(width: .infinity, height: .infinity))
            .preferredColorScheme(.dark)
    }
}
