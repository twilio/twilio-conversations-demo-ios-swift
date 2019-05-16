//
//  MessagesManagerProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol MessagesManagerProtocol: AnyObject {

    // MARK: - Properties
    var conversationsProvider: ConversationsProvider? { get }
    var conversationsRepository: ConversationsRepositoryProtocol? { get }
    var imageCache : ImageCache { get }
    var delegate: MessageManagerDelegate? { get set }
    var conversationSid: String! { get set }

    // MARK: - Methods for managing conversation messages
    func sendTextMessage(to conversationSid: String, with body: String, completion: @escaping (Error?) -> Void)
    func retrySendMessageWithUuid(_ uuid: String, _ completion: ((Error?) -> Void)?)
    func notifyTypingOnConversation(_ conversationSid: String)
    func reactToMessage(withSid messageSid: String, withReaction reaction: ReactionType)
    func sendMediaMessage(onConversation: String, inputStream: InputStream, mimeType:String, inputSize: Int)
    func startMediaMessageDownloadForIndex(_ messageIndex: UInt)
    func retrySendMediaMessageWithUuid(_ messageUuid: String)
    func removeMessage(withIndex messageIndex: UInt, messageSid: String)
    func isCurrentUserAuthorOf(messageWithSid: String) -> Bool
}
