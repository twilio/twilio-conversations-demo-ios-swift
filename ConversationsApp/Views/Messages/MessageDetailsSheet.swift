//
//  MessageDetailsSheet.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 30.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

// MessageDetailsSheet shows buttons to react and message options.
// Invoked by long tap on the message.

struct MessageDetailsSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isPresenting: Bool
    @State private var showShareSheet = false
    
    var viewModel: MessageBubbleViewModel
    var tapReactionAction: (() -> Void)?
    var copyAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ActionSheetIndicator()
            
            ReactionsPanel(viewModel, tapReactionAction: onTapReaction)
            
            if (viewModel.contentCategory == .text) {
                MessageActionRow(text: NSLocalizedString("message.details.copy", comment: "Action for copying the body of the selected message"), icon: Image(systemName: "doc.on.doc"), action: copyTextAction)
            }
            
            let shareText = NSLocalizedString("message.details.share", comment: "Action for sharing the body or attachments of the selected message")
            MessageActionRow(text: shareText, icon: Image(systemName: "square.and.arrow.up"), action: viewModel.contentCategory == .text ? copyTextAction : shareAction).disabled(viewModel.contentCategory == .file && viewModel.downloadedMediaAttachmentURL == nil)
                .sheet(isPresented: self.$showShareSheet) {
                    if (viewModel.contentCategory == .image && viewModel.image != nil) {
                        ShareSheetView(itemsToShare: [viewModel.imageDetail.image], viewModel: viewModel)
                    } else if viewModel.contentCategory == .file, let url = viewModel.downloadedMediaAttachmentURL {
                        ShareSheetView(itemsToShare: [url], viewModel: viewModel)
                    }
                }
            
            if (viewModel.direction == .outgoing) {
                MessageActionRow(text: NSLocalizedString("message.details.delete", comment: "Action for deleting the selected message"), icon: Image(systemName: "trash"), rowType: .destructive, action: deleteTextAction)
            }
            
            Spacer()
        }
    }
    
    func onTapReaction() {
        tapReactionAction?()
        isPresenting.toggle()
    }
    
    func copyTextAction() {
        let clipboard = UIPasteboard.general
        clipboard.string = viewModel.text.string
        isPresenting.toggle()
        copyAction?()
    }
    
    func shareAction() {
        showShareSheet = true
    }
    
    func deleteTextAction() {
        isPresenting.toggle()
        deleteAction?()
    }
}

struct ActionSheetIndicator: View {
    var body: some View {
        Capsule()
            .frame(width: 44, height: 6)
            .foregroundColor(Color("LightBorderColor"))
            .padding(.vertical, 12)
    }
}
    
struct ShareSheetView: View {
    var itemsToShare: [Any]
    var viewModel: MessageBubbleViewModel
    
    var body: some View {
        ShareSheet(activityItems: itemsToShare)
            .navigationBarTitle(Text(viewModel.mediaAttachmentName), displayMode: .inline)
    }
}

// ReactionsDetailSheet shows buttons to react and detailed reactions info.
// Invoked by long tap on the reactions.

struct ReactionDetailsSheet: View {
    @Environment(\.presentationMode) var presentationMode
    var viewModel: MessageBubbleViewModel

    var body: some View {
        VStack {
            ActionSheetIndicator()
            
            Text("Reactions")
            ReactionsPanel(viewModel)
            
            Spacer()
        }
    }
}
