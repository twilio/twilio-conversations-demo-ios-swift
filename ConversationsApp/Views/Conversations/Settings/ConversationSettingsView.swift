//
//  ConversationSettingsView.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-02-11.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI
import Combine
import TwilioConversationsClient

struct ConversationSettingsView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var participantsManager: ParticipantsManager

    @StateObject private var viewModel = ConversationSettingsViewModel()
    @State private var cancellableSet: Set<AnyCancellable> = []
    
    let conversation: PersistentConversationDataItem
    
    @State var showingAddParticipantSheet: Bool = false
    @State var showingRenameConversationSheet: Bool = false
    @State var showingParticipantActions: Bool = false
    @State var showingDeleteConfirmation: Bool = false
    @State var showingLeaveConfirmation: Bool = false
    @State var addParticipantFlow: AddParticipantFlow = .sms
    @State var selectedParticipant: PersistentParticipantDataItem? = nil
    
    @State var alertError: Error? = nil
    @State var showingAlert: Bool = false

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                VStack {
                    Text("conversation.settings.subtitle")
                        .font(Font.system(size: 14.0, weight: .medium))
                        .foregroundColor(Color("WeakTextColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 24.0, leading: 16, bottom: 8, trailing: 16))
                    
                    VStack(spacing: 0) {
                        ConversationSettingsRow(
                            title: NSLocalizedString("conversation.settings.edit.title", comment: "Action indicating the user can edit this conversation's name"),
                            subtitle: NSLocalizedString("conversation.settings.edit.subtitle", comment: "Indicates the current name of this conversation") + conversation.title,
                            icon: Image(systemName: "pencil")
                        ) {
                            showingRenameConversationSheet.toggle()
                        }
                        .sheet(isPresented: $showingRenameConversationSheet) {
                            RenameConversationSheet(isPresented: $showingRenameConversationSheet, name: conversation.title)
                        }
                        
                        let notificationsTitleKey = conversation.muted ? "conversation.settings.unmute.title" : "conversation.settings.mute.title"
                        let notificationsSubtitleKey = conversation.muted ? "conversation.settings.unmute.subtitle" : "conversation.settings.mute.subtitle"
                        let notificationsIcon = conversation.muted ? "bell" : "bell.slash"
                        
                        ConversationSettingsRow(
                            title: NSLocalizedString(notificationsTitleKey, comment: "Action indicating the user can stop notifications for this conversation"),
                            subtitle: NSLocalizedString(notificationsSubtitleKey, comment: "Description of what the mute action will do"),
                            icon: Image(systemName: notificationsIcon)
                        ) {
                            conversationManager.toggleMute(onConversation: conversation)
                        }
                        
                        ConversationSettingsRow(
                            title: NSLocalizedString("conversation.settings.leave.title", comment: "Action indicating the user can delete this conversation"),
                            subtitle: NSLocalizedString("conversation.settings.leave.subtitle", comment: "Description of what the leave action will do"),
                            icon: Image("trashIcon"),
                            type: .destructive
                        ) {
                            showingLeaveConfirmation.toggle()
                        }
                        .alert(isPresented: $showingLeaveConfirmation) {
                            let title = NSLocalizedString("leave.confirmation.title", comment: "Title for confirming that the user wants to leave this conversation")
                            return Alert(
                                title: Text(title),
                                message: Text("leave.confirmation.description"),
                                primaryButton: .default(Text("Cancel"), action: {}),
                                secondaryButton: .destructive(Text("leave.confirmation.action"), action: {
                                    conversationManager.leave(conversation: conversation)
                                })
                            )
                        }
                    }
                    .padding(.bottom, 48)
                    
                    if (getParticipantCount() < 2) {
                        EmptyParticipantsSection()
                    } else {
                        Text(NSLocalizedString("conversation.settings.participants.title", comment: "Subtitle indicating the number of participants in the current conversation") + "(\(getParticipantCount()))")
                            .font(Font.system(size: 14.0, weight: .medium))
                            .foregroundColor(Color("WeakTextColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 0.0, leading: 16, bottom: 8, trailing: 16))
                        
                        AddParticipantRow(tapActionSheetItem: tapActionSheetItem)
                        
                        LazyVStack {
                            ForEach(participantsManager.participants, id: \.id) { participant in
                                ParticipantRow(name: participant.getDisplayName()) {
                                    selectedParticipant = participant
                                    showingParticipantActions.toggle()
                                }
                            }
                        }
                        .alert(isPresented: $showingAlert) {
                            if (showingDeleteConfirmation) {
                                let title = String(format: NSLocalizedString("participant.remove.confirmation.title", comment: "Title for confirming that the user wants to remove this participant from the conversation"), getSelectedParticipantName())
                                return Alert(
                                    title: Text(title),
                                    message: Text("participant.remove.confirmation.description"),
                                    primaryButton: .default(Text("Cancel"), action: {
                                        showingDeleteConfirmation = false
                                    }),
                                    secondaryButton: .destructive(Text("participant.remove.confirmation.action"), action: {
                                        showingDeleteConfirmation = false
                                        removeParticipant(selectedParticipant?.sid ?? "")
                                    })
                                )
                            } else {
                                let title = Text("participant.remove.error.title")
                                if let alertError = alertError as? TCHError {
                                    let description = String(format: NSLocalizedString("participant.remove.error.description", comment: "Generic error description containing both the error code and error message"), String(alertError.code), alertError.localizedDescription)
                                    return Alert(title: title, message: Text(verbatim: description), dismissButton: .default(Text("dialog.close"), action: { self.alertError = nil }))
                                }
                                
                                let description = alertError?.localizedDescription ?? ""
                                return Alert(title: title, message: Text(description), dismissButton: .default(Text("dialog.close"), action: { alertError = nil }))
                            }
                        }
                        .sheet(isPresented: $showingAddParticipantSheet) {
                            AddParticipantSheet(isPresented: $showingAddParticipantSheet, flow: $addParticipantFlow)
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle(Text("conversation.settings.title")) // MARK: ios 14+
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                getStatusBanner(event: viewModel.currentConversationEvent)
                
            }
        }
        .confirmationDialog( //iOS15.0+ only
            getSelectedParticipantName(),
            isPresented: $showingParticipantActions,
            titleVisibility: .visible)
        {
            Button("participant.remove.sheet.action", role: .destructive) {
                showingDeleteConfirmation.toggle()
                showingAlert.toggle()
            }
        }
        .onAppear(perform: {
            conversationManager.conversationEventPublisher.sink(receiveValue: { conversationEvent in
                viewModel.registerForConversationEvents(conversationEvent)
            })
            .store(in: &cancellableSet)
        })
    }
    
    func getSelectedParticipantName() -> String {
        return selectedParticipant?.getDisplayName() ?? ""
    }
    
    func getParticipantCount() -> Int {
        return participantsManager.participants.count
    }
    
    func tapActionSheetItem(_ flow: AddParticipantFlow) {
        addParticipantFlow = flow
        showingAddParticipantSheet.toggle()
    }
    
    func removeParticipant(_ sid: String) {
        if let conversationSid = conversation.sid {
            participantsManager.removeParticipant(participantSid: sid, conversationSid: conversationSid) { error in
                if let error = error {
                    print("Error removing \(sid) from \(conversationSid): \(error.localizedDescription)")
                    alertError = error
                    showingAlert.toggle()
                } else {
                    print("Removed \(sid)")
                }
            }
        }
    }
}

@ViewBuilder private func getStatusBanner(event: ConversationEvent?) -> some View {
    switch event {
        case .participantAdded:
            withAnimation {
                GlobalStatusView(message: NSLocalizedString("conversation.status.participant_added", comment: "Notification indicating that the new participant was successfully added"), kind: .success)
            }
        case .participantRemoved:
            withAnimation {
                GlobalStatusView(message: NSLocalizedString("conversation.status.participant_removed", comment: "Notification indicating that the selected participant was successfully removed"), kind: .success)
            }
        case .notificationsTurnedOn:
            withAnimation  {
                GlobalStatusView(message: NSLocalizedString("notification.off.label", comment: "Notification indicating that the conversation was successfully muted"), kind: .success)
            }
        case .notificationsTurnedOff:
            withAnimation {
                GlobalStatusView(message: NSLocalizedString("notification.on.label", comment: "Notification indicating that the conversation was successfully unmuted"), kind: .success)
            }
        default:
            EmptyView()
    }
}

struct ConversationSettingsView_Previews: PreviewProvider {
    

    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let items: [PersistentConversationDataItem.Decode] = load("testConversations.json")
        
        ConversationSettingsView(conversation: items[0].conversation(inContext: appModel.getManagedContext()))
            .environmentObject(appModel)
            .environmentObject(appModel.conversationManager)
            .environmentObject(appModel.participantsManager)
    }
}
