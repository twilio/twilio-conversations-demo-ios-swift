//
//  AppDelegate.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        navigateToInitialScreen()
        UNUserNotificationCenter.current().delegate = self
        registerForAPNSNotifications()
        return true
    }

    func navigateToInitialScreen() {
        window = UIWindow()

        let signInController = SignInController()
        window?.rootViewController = signInController.signInContainerVC
        window?.makeKeyAndVisible()
    }

    func registerForPushNotifications() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
          print("Permission granted: \(granted)")
          guard granted else { return }
          self?.registerForAPNSNotifications()
      }
    }

    func registerForAPNSNotifications() {
      UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        if settings.authorizationStatus == .authorized {
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
        } else {
            self.registerForPushNotifications()
        }
      }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Received device push token")
        ConversationsRepository.shared.devicePushToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get push token, error: %@", error)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageType = userInfo["twi_message_type"] as? String {
            switch messageType {
            case "twilio.conversation.new_message", "twilio.conversation.added_to_conversation":
                if let conversationSid = userInfo["conversation_sid"] as? String {
                    ConversationsRepository.shared.navigateToConversationWithSid = conversationSid
                }
            case "twilio.conversation.removed_from_conversation":
                print("User has been removed from conversation")
            default:
                print("Not supported message type \(messageType)")
            }
        }

        if let conversationsClient = ConversationsRepository.shared.conversationsProvider.conversationsClient {
           conversationsClient.handleNotification(userInfo) { result in
               if !result.isSuccessful {
                   print("Handling of notification was not successful")
               }
           }
       }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
