//
//  FileAttachmentSheet.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-26.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct FileAttachmentSheet: View {
    @Binding var isPresented: Bool
    @State var showingShareSheet = false
    let filename: String
    let fileURL: URL

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                WebView(url: fileURL)
            }
            .navigationBarTitle(Text(filename), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .navigationBarItems(trailing: Button(action: {
                showingShareSheet.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color("LinkTextColor"))
            })
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [fileURL])
            }
        }
    }
}
