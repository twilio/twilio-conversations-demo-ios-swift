//
//  DebugView.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 02.11.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import SwiftUI

enum DebugError: Error {
    case runtimeError(String)
}

enum CrashSource {
    case conversationList
}

struct DebugView: View {

    // MARK: View
    // JFYI: to make formatting easier make extension methods like brandPadding() etc
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Simulate a crash")
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
                    .padding(.top, 16)
                Button(action: {
                    do {
                        try generateCrash(type: CrashSource.conversationList)
                    } catch DebugError.runtimeError(let errorMessage) {
                        let nserror = DebugError.runtimeError(errorMessage)
                        fatalError("Error info: \(nserror)")
                    } catch {
                        print("Error info: \(error)")
                    }
                }) {
                    VStack(alignment: .leading) {
                        Text("ConversationList.swift")
                            .font(.system(size: 16))
                            .foregroundColor(Color("TextColor"))
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
                        Text("Simulate a crash from your application")
                            .font(.system(size: 14))
                            .foregroundColor(Color("WeakTextColor"))
                    }
                }
                
                Divider()
                    .foregroundColor(Color("WeakTextColor"))

                Text("Use these crash simulations to check that you have properly installed Crashlytics support and uploaded all necessary files to the server, like debug symbols.")
                    .font(.system(size: 14))
                    .foregroundColor(Color("WeakTextColor"))
                    .padding(.bottom, 16)
                
                getAppVersionString()
                    .font(Font.system(size: 14.0))
                    .foregroundColor(Color("WeakTextColor"))
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("debug.label", displayMode: .inline)
        }
    }
}

func generateCrash(type: CrashSource) throws {
    if (type == CrashSource.conversationList) {
        throw DebugError.runtimeError("Simulated crash in ConversationList.swift")
    }
}

@ViewBuilder private func getAppVersionString() -> some View {
    if let mainBundle  = Bundle.main.infoDictionary,
       let versionNumber = mainBundle["CFBundleShortVersionString"] as? String,
       let buildNumber = mainBundle["CFBundleVersion"] as? String {
        let versionString = String(format: NSLocalizedString("debug.app_version", comment: "Text describing the current app version number and build number"), versionNumber, buildNumber)
        Text(versionString)
    } else {
        EmptyView()
    }
}

// MARK: Preview
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
