//
//  MessageBubbleCell.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import SwiftUI
import BottomSheet

struct MessageBubbleView: View {
    
    @ObservedObject var viewModel: MessageBubbleViewModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var messagesManager: MessagesManager
    
    @State private var whichSheet: ShowWhichDetails = .message
    @State private var showingMessageDetailsSheet = false
    @State private var showingReactionsDetailsView = false
    @State private var showingDeleteConfirmation = false
    @State private var showingFileAttachment = false
    
    var body: some View {
        HStack(alignment: .top) {
            if viewModel.direction == .incoming {
                VStack {
                    Spacer().frame(height: 24)
                    viewModel.icon
                        .resizable()
                        .padding(8)
                        .foregroundColor(Color("TextColor"))
                        .background(Color("UserBackgroundColor"))
                        .clipShape(Circle())
                        .frame(width: 32, height: 32)
                }
                .padding(.leading, 16)
                ZStack(alignment: .bottomLeading) {
                    VStack(alignment: .leading) {
                        Text(viewModel.author)
                            .lineLimit(1)
                            .foregroundColor(Color("WeakTextColor"))
                            .font(.system(size: 14))
                            .padding(.bottom, -4)
                        VStack(alignment: .leading) {
                            if (viewModel.contentCategory != .text) {
                                MediaAttachmentView(viewModel)
                            }
                            MessageTextView(viewModel)
                            MessageDateView(viewModel, isInbound: true)
                        }
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.incomingMessageBackgroundColor))
                    }.padding(.bottom, 4)
                    HStack {
                        TappableReactionView(viewModel: viewModel, showingReactionsDetailsView: $showingReactionsDetailsView, showingDetailSheet: $showingMessageDetailsSheet, whichSheet: $whichSheet)
                        Spacer()
                    }
                }
                .padding(.bottom, 22)
            } else { // outgoing message
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    VStack(alignment: .trailing) {
                        if (viewModel.contentCategory != .text) {
                            MediaAttachmentView(viewModel)
                        }
                        MessageTextView(viewModel)
                        MessageDateView(viewModel, isInbound: false)
                    }
                    .background(RoundedRectangle(cornerRadius: 8)
                    .fill(Color.outgoingMessageBackgroundColor))
                    .padding(.bottom, 4)
                    
                    //reaction
                    HStack {
                        Spacer()
                        TappableReactionView(viewModel: viewModel, showingReactionsDetailsView: $showingReactionsDetailsView, showingDetailSheet: $showingMessageDetailsSheet, whichSheet: $whichSheet)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 32))
            }
        }
        .padding(.bottom, 4)
        .onTapGesture {
            switch (viewModel.attachmentState) {
            case .downloaded:
                showingFileAttachment.toggle()
                break
            case .notDownloaded:
                viewModel.startToDownloadIfNeeded(appModel: appModel)
                break
            default:
                break
            }
            
        }
        .onLongPressGesture {
            whichSheet = .message
            showingMessageDetailsSheet.toggle()
        }
        .sheet(isPresented: $showingFileAttachment) {
            if let url = viewModel.downloadedMediaAttachmentURL {
                FileAttachmentSheet(isPresented: $showingFileAttachment, filename: viewModel.mediaAttachmentName, fileURL: url)
            } else {
                EmptyView()
            }
        }
        .bottomSheet(isPresented: $showingMessageDetailsSheet, detents: [.medium()]) {
            MessageDetailsSheet(isPresenting: $showingMessageDetailsSheet, viewModel: self.viewModel, tapReactionAction: tapReactionAction, copyAction: copyAction, deleteAction: deleteAction)
                .environmentObject(appModel)
        }
        .bottomSheet(isPresented: $showingReactionsDetailsView, detents: viewModel.fewParticipantsReacted ? [.medium()] : [.large()]) {
            ReactionsDetailsView(viewModel: viewModel, isPresenting: $showingReactionsDetailsView, tapReactionAction: tapReactionAction)
                .environmentObject(appModel)
        }
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("message.details.delete_title"),
                message: Text("message.details.delete_description"),
                primaryButton: .default(
                    Text("Cancel"),
                    action: {}
                ),
                secondaryButton: .destructive(
                    Text("message.details.delete"),
                    action: { messagesManager.deleteMessage(viewModel.source) }
                )
            )
        }
    }

    // MARK: - Actions

    func tapReactionAction() {
        messagesManager.updateMessage(attributes: viewModel.source.attributesDictionary, for: viewModel.source.messageIndex, conversationSid: viewModel.source.conversationSid)
    }
    
    func copyAction() {
        messagesManager.copyMessage()
    }
    
    func deleteAction() {
        showingDeleteConfirmation.toggle()
    }
}

fileprivate enum ShowWhichDetails {
    case message, reactions
}

struct TappableReactionView: View {
    
    @StateObject var viewModel: MessageBubbleViewModel
    @Binding var showingReactionsDetailsView: Bool
    @Binding var showingDetailSheet: Bool
    @Binding fileprivate var whichSheet: ShowWhichDetails

    var body: some View {
        if (viewModel.showReactions) {
            ReactionsView(viewModel: ReactionsViewModel(reactions: viewModel.reactions), currentUserReactedToMessage: viewModel.currentUserReactedToMessage)
                .offset(y: 24)
                .onTapGesture {
                    whichSheet = .message
                    showingReactionsDetailsView.toggle()
                }
                .onLongPressGesture {
                    whichSheet = .reactions
                    showingDetailSheet.toggle()
                }
        }  
    }
}

struct PlaceholderImage: View {
    var body: some View {
        Image(systemName: "questionmark.app")
            .resizable()
            .frame(width: 64, height: 64)
            .scaledToFit()
    }
}

struct MessageTextView: View {
    private var viewModel: MessageBubbleViewModel
    
    var body: some View {
        if viewModel.contentCategory == .text {
            if viewModel.direction == .outgoing {
                Text(.init(viewModel.text))
                    .padding(EdgeInsets(top: 12, leading: 8, bottom: 8, trailing: 8))
                    .foregroundColor(Color("InverseTextColor"))
                    .font(.system(size: 16))
            } else {
                Text(.init(viewModel.text))
                    .padding(EdgeInsets(top: 12, leading: 8, bottom: 8, trailing: 8))
                    .foregroundColor(Color("TextColor"))
                    .accentColor(Color("LinkTextColor"))
                    .font(.system(size: 16))
            }
        }
    }
    
    init(_ model: MessageBubbleViewModel) {
        self.viewModel = model
    }
}

struct MessageDateView: View {
    private var viewModel: MessageBubbleViewModel
    private var isIncoming: Bool
    
    var body: some View {
        if (isIncoming) {    //Incoming message date
            Text(viewModel.formattedDate)
                .lineLimit(1)
                .foregroundColor(Color("WeakTextColor"))
                .font(.system(size: 12))
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 12, trailing: 8))
        } else {    //Outgoing message date
            Text(viewModel.formattedDate)
                .lineLimit(1)
                .foregroundColor(Color("InverseTextColor"))
                .font(.system(size: 12))
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 12, trailing: 8))
        }
    }
    
    init(_ model: MessageBubbleViewModel, isInbound: Bool) {
        self.viewModel = model
        self.isIncoming = isInbound
    }
}

// MARK: Previews

struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let bubbles: [PersistentMessageDataItem.Decode] = load("testMessages.json")
        let currentUser = "user00"
        let managedObjectContext = appModel.getManagedContext()
        
        List {
            ForEach(0..<100) { n in
                // Messages with reactions
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[5].message(inContext: managedObjectContext), currentUser: currentUser))
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[6].message(inContext: managedObjectContext), currentUser: currentUser))
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[7].message(inContext: managedObjectContext), currentUser: currentUser))
                // Regular messages
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[0].message(inContext: managedObjectContext), currentUser: currentUser))
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[1].message(inContext: managedObjectContext), currentUser: currentUser))
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[2].message(inContext: managedObjectContext), currentUser: currentUser))
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[3].message(inContext: managedObjectContext), currentUser: currentUser))
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[4].message(inContext: managedObjectContext), currentUser: currentUser))
                MessageBubbleView(viewModel: MessageBubbleViewModel(message: bubbles[8].message(inContext: managedObjectContext), currentUser: currentUser))
            }
        }
        .previewLayout(.fixed(width: 400, height: 700))
        .environmentObject(appModel)
    }
}
