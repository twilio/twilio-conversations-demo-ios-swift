//
//  MessageBubbleViewModel.swift
//  ConversationsApp
//
//  Created by Berkus Karchebnyy on 07.10.2021.
//  Copyright © 2021 Twilio, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import TwilioConversationsClient

// MARK: - Media

enum MessageType {
    case text, image, file
}

enum MediaAttachmentState {
    case notDownloaded, downloading, downloaded
}

struct MediaUploadStatus {
    let totalBytes: Int
    let bytesUploaded: Int
    let url: URL?

    var percentage: Double {
        if totalBytes == 0 {
            return 0
        }
        let pct = round(Double(bytesUploaded) / Double(totalBytes) * 100)
        return pct
    }

    static func from(mediaProperties: MediaMessageProperties) ->  MediaUploadStatus {
        return MediaUploadStatus(
            totalBytes: mediaProperties.messageSize ,
            bytesUploaded: mediaProperties.uploadedSize,
            url: mediaProperties.mediaURL
        )
    }
    
    static func invalid() -> MediaUploadStatus {
        return MediaUploadStatus(totalBytes: 0, bytesUploaded: 0, url: nil)
    }
}

struct ReactionDetailModel: Identifiable {
    
    let id = UUID()
    let identity: String
    var reactions: [ReactionType]
}

struct Reaction: Identifiable, Hashable {
    var id = UUID()
    var reaction: String
    var count: Int
}

class ReactionsViewModel: ObservableObject {
    @Published var reactions: [Reaction]
    
    init(reactions:  [Reaction]) {
        self.reactions = reactions
    }
}


// MARK: - Message View Model

final class MessageBubbleViewModel: ObservableObject, Identifiable, Hashable, Equatable {
    @Published var source: PersistentMessageDataItem
    var currentUser: String
    @Published var attachmentState: MediaAttachmentState = .notDownloaded
    @Published var image: UIImage?

    public var text: NSMutableAttributedString {
        get {
            let body = source.body ?? "<No message provided, should NOT happen (TODO: recheck for multi-media case)>"
            let attributedString  = NSMutableAttributedString(string: body)
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: body, options: [], range: NSRange(location: 0, length: body.utf16.count))
            var link: URL?

            for match in matches {
                guard let range = Range(match.range, in: body) else { continue }
                link = match.url
                let textRange = NSRange(range, in: body)

                attributedString.addAttribute(.link, value: link!, range: textRange)
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
                attributedString.addAttribute(.underlineColor, value: getURLUnderlineColor(), range: textRange)
            }
            return attributedString
        }
    }
    
    private func getURLUnderlineColor() -> UIColor {
        if direction == .outgoing {
            return UIColor(Color("InverseTextColor"))
        } else {
            return UIColor(Color("LinkTextColor"))
        }
    }

    public var author: String {
        get {
            source.author ?? "<unknown>"
        }
    }

    public var direction: MessageDirection {
        get {
            source.direction == MessageDirection.outgoing.rawValue ? .outgoing : .incoming
        }
    }

    public var formattedDate: String {
        get {
            guard let date = source.dateCreated else {
                return ""
            }
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            if Calendar.current.isDateInToday(date) {
                dateFormatter.dateStyle = .none
            } else {
                dateFormatter.dateStyle = .short
            }
            return dateFormatter.string(from: date)
        }
    }
    
    public var icon: Image {
        get {
            switch contentCategory {
            case .text:
                return Image(systemName: "person")
            case .image:
                return Image(systemName: "person.crop.square")
            case .file:
                return Image(systemName: "doc.text")
            }
        }
    }
    
    var contentCategory: MessageType {
        get {
            guard !(media?.sid ?? "").isEmpty else {
                return .text
            }
            if let mediaType = media?.contentType, ["image/jpeg", "image/png"].contains(mediaType) {
                return .image
            }
            return .file
        }
    }

    var mediaIconName: String {
        switch attachmentState {
        case .downloaded, .downloading: return "doc"
        case .notDownloaded: return "square.and.arrow.down"
        }
    }
    var mediaAttachmentName: String {
        return media?.filename ?? String()
    }
    
    var mediaAttachmentSize: String {
        return ByteCountFormatter.string(fromByteCount: media?.size ?? 0, countStyle: .file)
    }
    
    var downloadedMediaAttachmentURL: URL? {
        guard contentCategory == .file && attachmentState == .downloaded else {
            return nil
        }

        return MediaAttachmentHelper.getDownloadedFileURL(for: media)
    }
    
    func startToDownloadIfNeeded(appModel: AppModel) {
        guard contentCategory == .file && attachmentState == .notDownloaded else {
            return
        }
        let mediaDownloadHelper = MediaAttachmentHelper(appModel: appModel)
        mediaDownloadHelper.startDownloadingMedia(for: source.messageIndex, media: media, conversationSid: source.conversationSid, completion: { state in
            self.attachmentState = state
        })
    }
    
    var messageIndex: Int64 {
        return source.messageIndex
    }
    
    // MARK: - Images
    var imageDetail: ImageDetail {
        return ImageDetail(username: author, deliveryDetails: deliveryDetails, image: image!)
    }
    
    func getImage(for url: URL?) {
        guard let mediaUrl = url else {
            print("Error trying to get url to download media attachment.")
            return
        }
        guard let mediaSid = media?.sid else { return }
        UIImageLoader.loader.load(forMediaSid: mediaSid, url: mediaUrl) { image, error in
            if error == nil, let image = image {
                self.image = image
            }
        }
    }
    
    

    // MARK: Reactions
    
    var reactions: [Reaction] {
        get {
            var reactionsIdentifiable = [Reaction]()
            source.reactions.counts.sorted(by: <).forEach({ (key, value) in
                let reaction = Reaction(reaction: key, count: value)
                reactionsIdentifiable.append(reaction)
            })
            return reactionsIdentifiable
        }
    }
    
    var showReactions: Bool {
        get {
             source.reactions.convertToParticipantDictionary().count > 0
        }
    }
    
    var currentUserReactedToMessage: Bool {
        get {
            return source.reactions.includesReactionFrom(participant: currentUser)
        }
    }
  
    var deliveryDetails: String {
        get {
            let status = NSLocalizedString("message.send.status.sent", comment: "Sent")
            guard let date = source.dateUpdated ?? source.dateCreated else {
                return String()
            }
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            if Calendar.current.isDateInToday(date) {
                dateFormatter.dateStyle = .none
            } else {
                dateFormatter.dateStyle = .medium
            }
            return "\(status) \(dateFormatter.string(from: date))"
        }
    }
    
 

    // MessageDataListItem was the viewModel before, we now use this one, but initialise from the same source:
    init(message: PersistentMessageDataItem, currentUser: String) {
      self.currentUser = currentUser
      self.source = message
      Task {
        await MainActor.run {
          self.attachmentState = updateAttachmentStateIfNeeded()
        }
      }
    }
    
    private func updateAttachmentStateIfNeeded() -> MediaAttachmentState {
        guard contentCategory == .file else { return .notDownloaded }
        
        if MediaAttachmentHelper.doesFileExist(for: media) {
            return .downloaded
        }
        
        return .notDownloaded
    }

    // MARK: Functions for reaction sheet support

    func includesReaction(_ r: ReactionType, forIdentity identity: String) -> Bool {
        return source.reactions.includesReaction(r, forParticipant: identity)
    }
    
    func includesReactionForCurrentUser(_ r: ReactionType) -> Bool {
        return source.reactions.includesReaction(r, forParticipant: currentUser)
    }

    func toggleReaction(_ r: ReactionType, forIdentity identity: String) {
        source.reactions.toggleReaction(r, forParticipant: identity)
    }
    
    var reactionDetailList: [ReactionDetailModel] {
        var reactionDetailList = [ReactionDetailModel]()
        
        let participantsDictionary = source.reactions.convertToParticipantDictionary()
        for participant in participantsDictionary {
            let model = ReactionDetailModel(identity: participant.key, reactions: participant.value)
            reactionDetailList.append(model)
        }
        return reactionDetailList
    }
    
    var fewParticipantsReacted: Bool {
        let participantsDictionary = source.reactions.convertToParticipantDictionary()
        if participantsDictionary.count < 5 {
            return true
        }
        return false
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.source.uuid)
    }
    // MARK: - Equatable
    static func == (lhs: MessageBubbleViewModel, rhs: MessageBubbleViewModel) -> Bool {
        return lhs.source.uuid == rhs.source.uuid && lhs.source.messageIndex == rhs.source.messageIndex
    }
    
    //MARK: - Private
    private var media: PersistentMediaDataItem? {
        //For Demo Apps v1 we'll assume that mediaAttachment for a message only has 1 attachment.
        guard let attachedMedia = source.attachedMedia,
              let media = Array(attachedMedia).first as? PersistentMediaDataItem else {
                  return nil
        }
        return media
    }
}
