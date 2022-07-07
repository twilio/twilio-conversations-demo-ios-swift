//
//  UserProfileView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 22.10.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI
import TwilioConversationsClient

struct UserProfileView: View {

    // MARK: Environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var navigationHelper: NavigationHelper

    @State var showingLogoutConfirmation = false
    @State var showingEditUsernameSheet = false
    
    // MARK: View
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack {
                    HStack(alignment: .center) {
                        UserProfileRowDetails(identity: appModel.myIdentity, friendlyName: appModel.myUser?.friendlyName ?? appModel.myIdentity)
                        Spacer()
                    }
                    Divider()
                        .background(Color("LightBorderColor"))
                        .padding(.horizontal, -15)
                }
                Button(action: {
                    showingEditUsernameSheet.toggle()
                }) {
                    VStack(alignment: .leading) {
                        Text("userProfile.editProfile")
                            .font(Font.system(size: 16.0))
                            .foregroundColor(Color("TextColor"))
                            .padding(.bottom, 1)
                        Text("userProfile.editFriendlyName")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal)
                Divider()
                Button(action: {
                    showLogoutConfirmation()
                }) {
                    VStack(alignment: .leading) {
                        Text("userProfile.signout")
                            .font(Font.system(size: 16.0))
                            .foregroundColor(Color("ErrorTextColor"))
                            .padding(.bottom, 1)
                        Text("userProfile.signout.description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .sheet(isPresented: $showingEditUsernameSheet) {
                    EditUsernameView(isPresented: $showingEditUsernameSheet, friendlyName: appModel.myUser?.friendlyName ?? "")
                }
                .alert(isPresented: $showingLogoutConfirmation) {
                    Alert(
                        title: Text("userProfile.logout.title"),
                        message: Text("userProfile.logout.description"),
                        primaryButton: .default(
                            Text("Cancel"),
                            action: {}
                        ),
                        secondaryButton: .destructive(
                            Text("userProfile.signout"),
                            action: {
                                appModel.signOut()
                                appState.current = .signin
                                navigationHelper.currentTab = Tab.conversations
                                navigationHelper.currentScreen = nil
                            }
                        )
                    )
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Divider()
                Spacer()
            }.padding()
                .navigationBarTitle("profile.label", displayMode: .inline)
                .font(Font.system(size: 16.0, weight: .medium))
        }
    }

    private func showLogoutConfirmation() {
        showingLogoutConfirmation.toggle()
    }
}

struct UserProfileRowDetails: View {
    var identity: String
    var friendlyName: String
    
    var body: some View {
        DefaultAvatar(size: 48.0)
            .padding(12.0)
        VStack(alignment: .leading) {
            Text(identity)
                .font(Font.system(size: 16.0, weight: .bold))
                .foregroundColor(Color("TextColor"))
                .padding(.bottom, 1)
            Text(friendlyName)
                .font(Font.system(size: 14.0))
                .foregroundColor(Color("WeakTextColor"))
        }
    }
}

// MARK: Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        appModel.myIdentity = "mohana@owlshoes.com"
        appModel.myUser = TCHUser()
        return UserProfileView()
            .environmentObject(appModel)
    }
}
