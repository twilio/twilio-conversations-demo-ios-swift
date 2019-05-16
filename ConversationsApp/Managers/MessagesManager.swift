//
//  MessagesManager.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import TwilioConversationsClient

protocol MessageManagerDelegate: AnyObject {
    func onMessageManagerError(_ error: Error)
}

class MessagesManager: MessagesManagerProtocol {

    private(set) weak var conversationsProvider: ConversationsProvider?
    private(set) weak var conversationsRepository: ConversationsRepositoryProtocol?
    private(set) var imageCache: ImageCache
    internal weak var delegate: MessageManagerDelegate?
    private let messageManagerDispatch = DispatchQueue(label: "com.tiwlio.conversationsdemo.MessagesManager", qos: .userInitiated)

    private var momentaryConversationCache: MomentaryConversationCache?
    var conversationSid: String!

    
    // MARK: Intialization
    init(conversationsProvider: ConversationsProvider = ConversationsClientWrapper.wrapper,
         ConversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared,
         imageCache: ImageCache = DefaultImageCache.shared) {
        self.conversationsProvider = conversationsProvider
        self.conversationsRepository = ConversationsRepository
        self.momentaryConversationCache = MomentaryConversationCache(conversationsProvider: conversationsProvider)
        self.imageCache = imageCache
    }

    func sendTextMessage(to conversationSid: String, with body: String, completion: @escaping (Error?) -> Void) {
        guard let identity: String = conversationsProvider?.conversationsClient?.user?.identity else {
            return
        }

        guard body.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            return
        }

        // Inserting message into cache even before it's sent to other participants.
        let uuid = UUID().uuidString
        let outgoingMessage: MessageDataItem = MessageDataItem(uuid: uuid, direction: MessageDirection.outgoing,
                                                               author: identity, body: body, dateCreated: Date().timeIntervalSince1970,
                                                               sendStatus: MessageSendStatus.sending, conversationSid: conversationSid,
                                                               type: TCHMessageType.text)

        conversationsRepository?.insertMessages([outgoingMessage], for: conversationSid)
        sendMessage(outgoingMessage, completion: completion)
    }
    

    func retrySendMessageWithUuid(_ uuid: String, _ completion: ((Error?) -> Void)? = nil) {
        guard let localMessageData = self.conversationsRepository?.getMessageWithUuid(uuid).data,
              let localMessage = localMessageData.value?.first?.getMessageDataItem()else {
            completion?(ActionError.notAbleToRetrieveCachedMessage)
            return
        }

        if (localMessage.sendStatus != .error) {
            return
        }
        localMessage.sendStatus = .sending
        self.conversationsRepository?.updateMessages([localMessage])
        self.sendMessage(localMessage)
    }
    
    
    // MARK: Helpers

    func notifyTypingOnConversation(_ conversationSid: String) {
        momentaryConversationCache?.getConversation(with: conversationSid, onError: { error in
            if let error = error {
                self.delegate?.onMessageManagerError(error)
            }
        }) { conversation in
            conversation.typing()
        }
    }

    private func sendMessage(_ outgoingMessage: MessageDataItem, completion: ((Error?) -> Void)? = nil) {
        guard let conversationSid = outgoingMessage.conversationSid,
              let messageOptions = TCHMessageOptions()
                .withBody(outgoingMessage.body!)
                .withAttributes(TCHJsonAttributes.init(dictionary: outgoingMessage.attributesDictionnary), completion: nil) else {
            completion?(ActionError.notAbleToBuildMessage)
            return
        }

        momentaryConversationCache?.getConversation(with: conversationSid, onError: { error in
            completion?(error)
        }) { conversation in
            conversation.sendMessage(with: messageOptions) { (result, sentMessage) in
                if let error = result.error {
                    print("Error encountered while sending message: \(error)")
                    outgoingMessage.sendStatus = MessageSendStatus.error
                } else {
                    outgoingMessage.dateCreated = Date().timeIntervalSince1970
                    outgoingMessage.sid = sentMessage!.sid!
                    outgoingMessage.sendStatus = .sent
                    outgoingMessage.index = sentMessage!.index!.uintValue
                }
                self.conversationsRepository?.updateMessages([outgoingMessage])
                completion?(result.error)
            }
        }
    }

    func reactToMessage(withSid messageSid: String, withReaction reaction: ReactionType) {
        guard
            let messageToSend = conversationsRepository?.getMessageWithSid(messageSid),
            let userIdentity = conversationsProvider?.conversationsClient?.user?.identity
        else {
            delegate?.onMessageManagerError(ActionError.messagesNotAvailable)
            return
        }

        momentaryConversationCache?.getConversation(with: messageToSend.conversationSid!, onError: { _ in }) { conversation in
            conversation.message(withIndex: NSNumber(value: messageToSend.index)) { [weak self] result, message in
                messageToSend.reactions.tooggleReaction(recation: reaction, forParticipant: userIdentity)
                message?.setAttributes(TCHJsonAttributes(dictionary: messageToSend.attributesDictionnary)) { updateResult in
                    if (!updateResult.isSuccessful) {
                        guard let error = updateResult.error else {
                            self?.delegate?.onMessageManagerError(ActionError.unknown)
                            return
                        }
                        self?.delegate?.onMessageManagerError(error)
                    }
                }
            }
        }
    }

    func sendMediaMessage(onConversation: String, inputStream: InputStream, mimeType: String, inputSize: Int) {
        guard let identity: String = conversationsProvider?.conversationsClient?.user?.identity else {
            return
        }

        momentaryConversationCache?.getConversation(with: onConversation, onError: { _ in }) { [weak self] conversation in
            self?.sendMediaMessage(onConversation: conversation,
                                   author: identity,
                                   inputStream: inputStream,
                                   mimeType: mimeType,
                                   inputSize: inputSize)
        }
    }

    private func sendMediaMessage(onConversation conversation: TCHConversation,
                                  author: String,
                                  inputStream: InputStream,
                                  mimeType: String,
                                  inputSize: Int) {
        let result = imageCache.copyToAppCache(inputStream: inputStream)
        switch result {
        case .success(let url):
            print("[MediaMessage] Image copied to cache uploading to twilio")
            let uuid = UUID().uuidString
            let outgoingMessage = MessageDataItem(
                uuid: uuid,
                direction: MessageDirection.outgoing,
                author: author,
                body: nil,
                dateCreated: Date().timeIntervalSince1970,
                sendStatus: MessageSendStatus.sending,
                conversationSid: conversationSid,
                type: TCHMessageType.media
            )

            guard let mediaData = try? Data(contentsOf: url),
                  let messageOptions = TCHMessageOptions()
                    .withAttributes(TCHJsonAttributes(dictionary: outgoingMessage.attributesDictionnary), completion: nil) else {
                self.delegate?.onMessageManagerError(ActionError.notAbleToBuildMessage)
                return
            }

            outgoingMessage.mediaProperties = MediaMessageProperties(mediaURL: url, messageSize: inputSize, uploadedSize: 0)
            outgoingMessage.mediaStatus = .uploading
            outgoingMessage.conversationSid = conversationSid
            self.conversationsRepository?.updateMessages([outgoingMessage])

            messageOptions.withMediaStream(
                InputStream(data: mediaData),
                contentType: mimeType,
                defaultFilename: nil,
                onStarted: {
                    // Called when upload of media begins.
                    print("[MediaMessage] Media upload started")
                },
                onProgress: { (bytes) in
                    let updatedProperties = MediaMessageProperties(mediaURL: nil,
                                                                   messageSize: inputSize,
                                                                   uploadedSize: Int(bytes))
                    outgoingMessage.mediaProperties = updatedProperties
                    outgoingMessage.mediaStatus = .uploading
                    self.conversationsRepository?.updateMessages([outgoingMessage])
                },
                onCompleted:  { (mediaSid) in
                    print("[MediaMessage] Upload completed for sid \(mediaSid)")
                    outgoingMessage.mediaSid = mediaSid
                    outgoingMessage.mediaStatus = .uploaded
                    let updatedProperties = MediaMessageProperties(mediaURL: url,
                                                                   messageSize: inputSize,
                                                                   uploadedSize: inputSize)
                    outgoingMessage.mediaProperties = updatedProperties
                })

            conversation.sendMessage(with: messageOptions) { (result, message) in
                if !result.isSuccessful {
                    print("[MediaMessage] Media message has been sent succesfully")
                    outgoingMessage.sendStatus = .sent
                    outgoingMessage.mediaSid = message?.mediaSid
                    self.conversationsRepository?.updateMessages([outgoingMessage])
                } else {
                    print("[MediaMessage] Media message has been sent succesfully")
                    outgoingMessage.sendStatus = .error
                    self.conversationsRepository?.updateMessages([outgoingMessage])
                }
            }
            outgoingMessage.sendStatus = .error
            self.conversationsRepository?.updateMessages([outgoingMessage])

        case .failure (let error):
            self.delegate?.onMessageManagerError(ActionError.writeToCacheError)
            print("[MediaMessage] Unable to copy to app cache \(error)")
        }

    }

    func retrySendMediaMessageWithUuid(_ messageUuid: String) {
        messageManagerDispatch.async { [weak self] in
            guard let self = self else {
                return
            }
            self.momentaryConversationCache?.getConversation(with: self.conversationSid, onError: { [weak self] _ in
                self?.delegate?.onMessageManagerError(ActionError.notAbleToRetrieveCachedMessage)
            }) { conversation in
                guard let localMessageData = self.conversationsRepository?.getMessageWithUuid(messageUuid).data,
                      let localMessage = localMessageData.value?.first?.getMessageDataItem(),
                      let localMediaUrl = localMessage.mediaProperties?.mediaURL,
                      let messageSize = localMessage.mediaProperties?.messageSize,
                      let messageOptions = TCHMessageOptions()
                        .withAttributes(TCHJsonAttributes(dictionary: localMessage.attributesDictionnary), completion: nil),
                      let data = try? Data(contentsOf: localMediaUrl) else {
                    self.delegate?.onMessageManagerError(ActionError.notAbleToRetrieveCachedMessage)
                    return
                }

                localMessage.sendStatus = .sending
                // Reset the uploaded size to zero in case the first upload try was interrupted
                localMessage.mediaProperties = MediaMessageProperties.init(mediaURL: localMediaUrl, messageSize: messageSize, uploadedSize: 0)
                self.conversationsRepository?.updateMessages([localMessage])

                messageOptions.withMediaStream(
                    InputStream(data: data),
                    contentType: "image/jpeg",
                    defaultFilename: nil,
                    onStarted: {
                        // Called when upload of media begins.
                        print("[MediaMessage] Media upload started")
                    },
                    onProgress: { (bytes) in
                        let updatedProperties = MediaMessageProperties(mediaURL: nil,
                                                                       messageSize: messageSize,
                                                                       uploadedSize: Int(bytes))
                        localMessage.mediaProperties = updatedProperties
                        self.conversationsRepository?.updateMessages([localMessage])
                    },
                    onCompleted:  { (mediaSid) in
                        print("Media message upload completed")
                        let updatedProperties = MediaMessageProperties(mediaURL: nil,
                                                                       messageSize: messageSize,
                                                                       uploadedSize: messageSize)
                        localMessage.mediaProperties = updatedProperties
                        localMessage.mediaStatus = .uploaded
                        self.conversationsRepository?.updateMessages([localMessage])
                    })

                conversation.sendMessage(with: messageOptions) { result, message in
                    if result.isSuccessful {
                        print("Media message failed to be sent")
                        localMessage.sendStatus = .error
                    } else {
                        print("Media message Sent succesfully")
                        localMessage.sendStatus = .sent
                        localMessage.mediaSid = message?.mediaSid
                    }
                    self.conversationsRepository?.updateMessages([localMessage])
                }
            }
        }
    }

    func startMediaMessageDownloadForIndex(_ messageIndex: UInt) {
        messageManagerDispatch.async { [weak self] in
            guard let self = self else {
                NSLog("[MediaMessage] Download won't be happening as the identity or self can not be retreived")
                return
            }

            self.momentaryConversationCache?.getConversation(with: self.conversationSid, onError: { _ in }) { [weak self] conversation in
                conversation.message(withIndex: NSNumber(value: messageIndex)) { (result, tchMessage) in
                    NSLog("[MediaMessage] startMediaMessageDownloadForIndex\(messageIndex) -> Get message result \(result) -> \(tchMessage.debugDescription) ")
                    guard let self = self,
                          let message = tchMessage,
                          let messageSid = message.sid,
                          let messageDataItem = self.conversationsRepository?.getMessageWithSid(messageSid) else {
                        return
                    }

                    if (!self.isMessageNeedingDownload(mediaMessage: messageDataItem)) {
                        NSLog("[MediaMessage] No need to download the message with index \(messageIndex) ")
                        return
                    }

                    NSLog("[MediaMessage] We got what we need")
                    messageDataItem.conversationSid = self.conversationSid
                    messageDataItem.mediaStatus = .downloading
                    self.conversationsRepository?.updateMessages([messageDataItem])

                    message.getMediaContentTemporaryUrl { [weak self] _, urlString in
                        guard let url = URL(string: urlString ?? "invalid url" ) else {
                            NSLog("[MediaMessage] We got a wrong url from getMediaContentTemporaryUrl message with Index \(messageIndex)")
                            messageDataItem.mediaStatus = .error
                            self?.conversationsRepository?.updateMessages([messageDataItem])
                            return
                        }
                        self?.imageCache.copyToAppCache(locatedAt: url) { cachedResult in
                            switch cachedResult {
                            case .success(let image):
                                self?.messageManagerDispatch.async {
                                    messageDataItem.mediaProperties =
                                        MediaMessageProperties(mediaURL: image.url, messageSize: Int(message.mediaSize), uploadedSize: Int(message.mediaSize))
                                    messageDataItem.mediaStatus = .downloaded
                                    self?.conversationsRepository?.updateMessages([messageDataItem])
                                    NSLog("[MediaMessage][cache] Download succes for message with Index: \(messageIndex)")
                                }
                            case .failure(_):
                                messageDataItem.mediaStatus = .error
                                self?.conversationsRepository?.updateMessages([messageDataItem])
                                NSLog("[MediaMessage][cache] Download error for message with Index: \(messageIndex)")
                            }
                        }
                    }
                }
            }
        }
    }

    func isMessageNeedingDownload(mediaMessage: MessageDataItem) -> Bool {
        guard let mediaStatus = mediaMessage.mediaStatus else {
            return true
        }
        switch mediaStatus {
        case .downloading:
            return false
        case .downloaded, .uploaded:
            return !imageCache.hasDataForURL(url: mediaMessage.mediaProperties?.mediaURL)
        case .error:
            return true
        case .uploading:
            return false
        }
    }

    func removeMessage(withIndex messageIndex: UInt, messageSid: String) {
        messageManagerDispatch.async { [weak self] in
            guard let _self = self,
                  let conversationSid = self?.conversationSid else {
                return
            }
            let messageRetrievalRequest = MessageRetrievalRequestParameters(messageIndex: messageIndex, messageSid: messageSid, conversationSid: conversationSid)
            _self.conversationsProvider?.getMessage(parameters: messageRetrievalRequest) { result in
                switch result {
                case .failure(let error):
                    NSLog("[delete-message] Message not found, error \(error.localizedDescription)")
                    _self.delegate?.onMessageManagerError(error)
                case .success(let message):
                    NSLog("[delete-message] Message found, starting deletion")
                    _self.removeMessage(tchMessage: message, onConversationWithSid: conversationSid)
                }
            }
        }
    }

    private func removeMessage(tchMessage message: TCHMessage, onConversationWithSid conversationSid: String) {
        self.momentaryConversationCache?.getConversation(with: self.conversationSid, onError: { _ in }) {[weak self] conversation in
            guard let messageSid = message.sid else {
                return
            }

            conversation.remove(message) { tchResult in
                if let error = tchResult.error {
                    self?.delegate?.onMessageManagerError(error)
                    return
                }
                self?.conversationsRepository?.deleteMessagesWithSids([messageSid])
            }
        }
    }

    func isCurrentUserAuthorOf(messageWithSid sid: String) -> Bool {
        guard let message = self.conversationsRepository?.getMessageWithSid(sid),
              let identity: String = conversationsProvider?.conversationsClient?.user?.identity else {
            return false
        }
        return message.author == identity
    }

}
