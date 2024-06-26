//
//  MessageListView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 14.10.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//
// MARK: Working with sheet views
// https://medium.com/turkishkit/swiftui-managing-sheet-views-432bf129108e
// https://kristaps.me/blog/swiftui-modal-view/
// https://www.simpleswiftguide.com/how-to-present-sheet-modally-in-swiftui/
//

import SwiftUI
import Combine
import TwilioConversationsClient

enum MessageAction {
    case edit, remove
}

struct Messages: Identifiable {
    let id = UUID()
    let messages: [PersistentMessageDataItem]
}

struct MessageListView: View {
    
    // MARK: Observable
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var participantsManager: ParticipantsManager
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    //The message list view model should be an Observed object because we don't want to retain the view model once the view is destroyed
    @ObservedObject private var viewModel: MessageListViewModel
    private var conversation: PersistentConversationDataItem
    @State private var textToSend = ""
    @State private var showingPickerSheet = false
    @State private var cancellableSet: Set<AnyCancellable> = []
    private let messagesPaginationSize: UInt = 40
    private let unreadSectionHeaderId = "unreadSectionHeader"
    private let enableUnreadMessageSection = true
    @State private var showUnreadMessageSection = true
    @State private var messageCount: Int = 0
    @State private var isCancelled = false
    
    @State private var isShowingSendError = false
    @State private var sendError: TCHError? = nil

    // MARK: View
    var body: some View {
        let markAllMessagesReadTask = DispatchWorkItem {
            if (!isCancelled) {
                messagesManager.setAllMessagesRead(for: conversation.sid)
                showUnreadMessageSection = false
            }
        }
        ZStack(alignment: .center) {
            ZStack(alignment: .top) {
                VStack(alignment: .center) {
                    if isConversationNew() {
                        VStack() {
                            Spacer()
                            AddParticipantsButton()
                        }
                        .padding()
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView(.vertical) {
                                PullToRefresh(coordinateSpaceName: "messageListPullToRefresh")
                                    .refreshable {
                                        guard let lastMessage = messagesManager.messages.first else { return }
                                        messagesManager.loadMessages(for: conversation, before: lastMessage.messageIndex, max: messagesPaginationSize)
                                    }
                                LazyVStack {
                                    if (enableUnreadMessageSection) {
                                        // no section needed for read messages.
                                        ForEach(viewModel.readMessages, id: \.self) { (message) in
                                            MessageBubbleView(viewModel: MessageBubbleViewModel(message: message, currentUser: appModel.myIdentity))
                                                .listRowSeparator(.hidden) // MARK: ios 15+
                                                .frame(maxWidth: .infinity)
                                                .id(message.messageIndex)
                                        }
                                        if (viewModel.unreadReceivedMessages.count > 0) {
                                            if (showUnreadMessageSection) {
                                                ForEach(viewModel.unreadSection) { section in
                                                    Section(header: UnreadSectionHeaderView(unreadMessagesCount: viewModel.unreadReceivedMessages.count)
                                                                .id(unreadSectionHeaderId)) {
                                                        ForEach(section.messages, id: \.self) { message in
                                                            MessageBubbleView(viewModel: MessageBubbleViewModel(message: message, currentUser: appModel.myIdentity))
                                                                .listRowSeparator(.hidden) // MARK: ios 15+
                                                                .frame(maxWidth: .infinity)
                                                                .id(message.messageIndex)
                                                                .onAppear() {
                                                                    if (section.messages.last == message) {
                                                                        //Once we reach the last message, we are triggering a call to mark all messages as read, after 2 sec
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: markAllMessagesReadTask)
                                                                    }
                                                                }
                                                        }
                                                    }
                                                }
                                            } else {
                                                ForEach(viewModel.unreadReceivedMessages, id: \.self) { (message) in
                                                    MessageBubbleView(viewModel: MessageBubbleViewModel(message: message, currentUser: appModel.myIdentity))
                                                        .listRowSeparator(.hidden) // MARK: ios 15+
                                                        .frame(maxWidth: .infinity)
                                                        .id(message.messageIndex)
                                                        .onAppear() {
                                                            if (viewModel.unreadReceivedMessages.last == message) {
                                                                //Once we reach the last message, we are triggering a call to mark all messages as read
                                                                DispatchQueue.main.asyncAfter(deadline: .now(), execute: markAllMessagesReadTask)
                                                            }
                                                        }
                                                }
                                            }
                                        }
                                        ForEach(viewModel.unreadSentMessages, id: \.self) { (message) in
                                            MessageBubbleView(viewModel: MessageBubbleViewModel(message: message, currentUser: appModel.myIdentity))
                                                .listRowSeparator(.hidden) // MARK: ios 15+
                                                .frame(maxWidth: .infinity)
                                                .id(message.messageIndex)
                                        }
                                    } else {
                                        ForEach(messagesManager.messages, id: \.self) { (message) in
                                            MessageBubbleView(viewModel: MessageBubbleViewModel(message: message, currentUser: appModel.myIdentity))
                                                .listRowSeparator(.hidden) // MARK: ios 15+
                                                .frame(maxWidth: .infinity)
                                                .onAppear() {
                                                    if (messagesManager.messages.last == message) {
                                                        //Once we reach the last message, we are triggering a call to mark all messages as read, after 2 sec
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: markAllMessagesReadTask)
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            .onAppear() {
                                messageCount = messagesManager.messages.count
                                if (enableUnreadMessageSection) {
                                    // if there are unread messages, scroll to the unread section header.
                                    if viewModel.unreadReceivedMessages.count > 0 {
                                        proxy.scrollTo(unreadSectionHeaderId)
                                    } else {
                                        proxy.scrollTo(viewModel.readMessages.last?.messageIndex, anchor: .bottom)
                                        showUnreadMessageSection = false
                                    }
                                } else {
                                    guard messagesManager.messages.count > 1 else { return }
                                    proxy.scrollTo(messagesManager.messages[messagesManager.messages.count - 1])
                                }
                            }
                            .onChange(of: messagesManager.messages.count) { _ in
                                if (messageCount < messagesManager.messages.count) {
                                    withAnimation {
                                        if (messagesManager.messages[messagesManager.messages.count - 1].direction == MessageDirection.outgoing.rawValue) {
                                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: markAllMessagesReadTask)
                                        }
                                        proxy.scrollTo(messagesManager.messages[messagesManager.messages.count - 1])
                                    }
                                }
                                messageCount = messagesManager.messages.count
                            }
                            .coordinateSpace(name: "messageListPullToRefresh")
                        }
                    }
                    VStack {
                        HStack() {
                            // Typing participants area
                            if viewModel.isAnyParticipantTyping {
                                TypingView(label: viewModel.typingText)
                                Spacer()
                            }
                        }
                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                        HStack(alignment: .center) {
                            // Attach media button
                            Button(action: {
                                showingPickerSheet = true
                            }) {
                                Image("addAttachment")
                            }
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8))
                            // Input line
                            TextField("conversation.compose.bar.placeholder", text: $textToSend)
                                .accentColor(Color("LinkTextColor"))
                                .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 0))
                                .onChange(of: textToSend) { _ in
                                    appModel.typing(in: appModel.selectedConversation)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color("LightBorderColor"), lineWidth: 1))
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color("InverseTextColor")))
                            if (!textToSend.isEmpty) {
                                // Send button
                                Button(action: {
                                    messagesManager.sendMessage(toConversation: conversation, withText: textToSend, andMedia: viewModel.selectedImageURL, withFileName: viewModel.selectedFileName) { error in
                                        viewModel.clearSelectedImage()
                                        textToSend = ""
                                    }
                                }) {
                                    Text("Send")
                                        .foregroundColor(Color("LinkTextColor"))
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 16))
                    .background(Color("LightBackgroundColor"))
                }
                .navigationTitle(Text(appModel.selectedConversation?.title ?? ""))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action : {
                    self.mode.wrappedValue.dismiss()
                    isCancelled = true
                }){
                    HStack {
                        Image(systemName:"chevron.left")
                        Text("Back")
                            .font(.system(size: 16))
                            .foregroundColor(Color("InverseTextColor"))
                    }
                })
                .navigationBarItems(
                    trailing: NavigationLink(
                        destination: ConversationSettingsView(
                            conversation: conversation
                        )
                    ) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                            .frame(width: 24, height: 24, alignment: .center)
                    }
                )
                .alert(String(format: NSLocalizedString("dialog.error_code.title", comment: "Generic error dialog title with an error code"), String(sendError?.code ?? 0)), isPresented: $isShowingSendError) {
                    Button() {
                        sendImage()
                    } label: {
                        Text("Retry")
                    }
                    
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("Cancel")
                    }
                } message: {
                    Text(sendError?.localizedDescription ?? "")
                }
                .confirmationDialog("message.attachment.add.title", isPresented: $showingPickerSheet) {
                    Button("message.attachment.add.photo") {
                        viewModel.choosePhoto()
                    }
                    Button("message.attachment.add.camera") {
                        viewModel.takePhoto()
                    }
                } message: {
                    Text("message.attachment.add.title")
                }
                .fullScreenCover(isPresented: $viewModel.isPresentingImagePicker, content: { // MARK: ios 14+
                    ImagePicker(sourceType: viewModel.sourceType, completionHandler: viewModel.didSelectImage)
                })
                .onAppear(perform: {
                    messagesManager.subscribeMessages(inConversation: conversation)
                    participantsManager.subscribeParticipants(inConversation: conversation)
                    
                    messagesManager.$messages.sink(receiveValue: { messages in
                        viewModel.prepareMessages(conversation, messages, participantsManager.participants)
                    }).store(in: &cancellableSet)
                    
                    //We are subscribing here to the participant changes to update the unread section
                    participantsManager.$participants.sink(receiveValue: { participant in
                        viewModel.prepareMessages(conversation, messagesManager.messages, participantsManager.participants)
                    }).store(in: &cancellableSet)
                    
                    // on entering a conversation load all unread messages or messagesPaginationSize, whichever is greater.
                    messagesManager.loadLastMessagePageIn(conversation, max: max(messagesPaginationSize, UInt(conversation.unreadMessagesCount)))
                    
                    let parsedConversation = PersistanceDataAdapter.transform(from: conversation)
                    
                    viewModel.setConversation(parsedConversation)
                    appModel.typingPublisher.sink(receiveValue: { typing in
                        viewModel.registerForTyping(typing)
                    })
                        .store(in: &cancellableSet)
                    
                    conversationManager.conversationEventPublisher.sink(receiveValue: { conversationEvent in
                        viewModel.registerForConversationEvents(conversationEvent)
                    })
                        .store(in: &cancellableSet)
                })
                
                getStatusBanner(event: viewModel.currentConversationEvent)
            }
            
            if (viewModel.isPresentingImagePreview) {
                ImagePreviewAlert(viewModel: viewModel, onConfirm: {
                    sendImage()
                })
            }
        }
    }
    
    // MARK: Init
    init(conversation: PersistentConversationDataItem, viewModel: MessageListViewModel) {
        self.conversation = conversation
        self.viewModel = viewModel
    }
    
    /**
     Conversation is new if there are no messages & only has 1 participant
     When a new conversation is created, it has 1 participant by default, that is who created that conversation.
     */
    private func isConversationNew() -> Bool {
        return messagesManager.messages.count == 0 && (appModel.selectedConversation?.participantsCount ?? 0) < 2
    }
    
    private func sendImage() {
        if (viewModel.selectedImage != nil) {
            messagesManager.sendMessage(toConversation: conversation, withText: textToSend, andMedia: viewModel.selectedImageURL, withFileName: viewModel.selectedFileName) { error in
                if let error = error {
                    sendError = error
                    isShowingSendError = true
                } else {
                    DispatchQueue.main.async {
                        viewModel.clearSelectedImage()
                        textToSend = ""
                    }
                }
            }
        }
    }
}

struct UnreadSectionHeaderView: View {
    var unreadMessagesCount: Int
    
    var body: some View {
        HStack() {
            Text(String(format: NSLocalizedString("conversation.unreadMessages.header", comment: ""), "\(unreadMessagesCount)"))
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("LinkTextColor"))
            Spacer()
        }
        .padding(.horizontal, 0)
        .padding(.vertical, 5)
        .background(Color("BackgroundPrimaryLightest"))
    }
}

@ViewBuilder private func getStatusBanner(event: ConversationEvent?) -> some View {
    if event == .messageCopied {
        withAnimation {
            GlobalStatusView(message: NSLocalizedString("conversation.status.message_copied", comment: "Notification indicating that the message was successfully copied"), kind: .success)
        }
    } else if event == .messageDeleted {
        withAnimation {
            GlobalStatusView(message: NSLocalizedString("conversation.status.message_deleted", comment: "Notification indicating that the message was successfully deleted"), kind: .success)
        }
    } else {
        EmptyView()
    }
}

// MARK: Preview
struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let items: [PersistentConversationDataItem.Decode] = load("testConversations.json")
        let messageListViewModel = MessageListViewModel()
    
        MessageListView(conversation: items[0].conversation(inContext: appModel.getManagedContext()), viewModel: messageListViewModel)
            .environmentObject(appModel)
            .environmentObject(appModel.conversationManager)
            .environmentObject(appModel.messagesManager)
            .environmentObject(appModel.participantsManager)
    }
}
