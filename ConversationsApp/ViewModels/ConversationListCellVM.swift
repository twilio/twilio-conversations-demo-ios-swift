//
//  ConversationListCellVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient.TCHConstants

class ConversationListCellViewModel {

    // MARK: Properties

    let sid: String
    let name: String
    let participantsCount: String?
    let unreadMessageCount: Int
    let notificationLevel: MuteStatus
    let lastMessageDate: String

    private(set) var lastMessageState: MessageType = .none

    weak var delegate: ConversationListActionListener?
    var userInteractionState = UserInteractionState()

    lazy var conversationViewModel = ConversationViewModel(conversationSid: sid)

    // MARK: Intialization

    init?(item: ConversationDataItem) {
        sid = item.sid
        name = item.friendlyName.isEmpty ? item.sid : item.friendlyName
        unreadMessageCount = item.unreadMessagesCount
        notificationLevel = MuteStatus(from: item.notificationLevel)

        let format = NSLocalizedString("number_of_participants", comment: "Number of participants in a conversations conversation")
        self.participantsCount = String.localizedStringWithFormat(format, item.participantsCount)

        lastMessageDate = Self.formattedDate(from: Date(timeIntervalSince1970: item.lastMessageDate))

        listenForMessages()
    }

    deinit {
        conversationViewModel.observableMessageList.removeObserver(self)
    }

    func listenForMessages() {
        conversationViewModel.observableMessageList.observe(with: self) { [weak self] dataList in
            guard let lastMessage = dataList?.filter({ $0.dateCreated != nil }).sorted(by: { $0.dateCreated! < $1.dateCreated! }).last else {
                return
            }

            self?.updateLastMessageState(with: lastMessage.getMessageDataItem())
        }
    }

    private func updateLastMessageState(with dataItem: MessageDataItem) {
        if dataItem.type == .media {
            if dataItem.direction == .incoming {
                lastMessageState = .media(dataItem.author, .received)
                return
            }

            guard let mediaStatus = dataItem.mediaStatus else {
                lastMessageState = .media(dataItem.author, .sent(.sent))
                return
            }

            switch mediaStatus {
            case .error:
                lastMessageState = .media(dataItem.author, .sent(.error(.failedToSend)))
            case .uploaded:
                lastMessageState = .media(dataItem.author, .sent(.sent))
            case .uploading:
                lastMessageState = .media(dataItem.author, .sent(.sending))
            default:
                return
            }
        } else {
            guard let body = dataItem.body else {
                lastMessageState = .none
                return
            }

            if dataItem.direction == .incoming {
                lastMessageState = .text(body, .received)
                return
            }

            let status: MessageType.MessageStatus.SendingStatus
            switch dataItem.sendStatus {
            case .error:
                status = .error(.failedToSend)
            case .sending:
                status = .sending
            case .sent:
                status = .sent
            case .undefined:
                status = .error(.other)
            }
            lastMessageState = .text(body, .sent(status))
        }
    }

    private static func formattedDate(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        } else {
            let yearRange = calendar.range(of: .day, in: .year, for: Date())!
            let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 1

            var stringFormatName: String
            var count: Int
            switch days {
            case 0...6:
                stringFormatName = "number_of_days"
                count = days
            case yearRange:
                stringFormatName = "number_of_weeks"
                count = days / 7
            default:
                stringFormatName = "number_of_years"
                count = calendar.dateComponents([.year], from: date, to: Date()).year ?? 1
            }
            let stringFormat = NSLocalizedString(stringFormatName, comment: "Number of days, weeks or years")
            return String.localizedStringWithFormat(stringFormat, count)
        }
    }

    struct UserInteractionState {

        var isJoining = Observable<Bool>(false)
        var isChangingNotificationLevel = false
        var isLeavingConversation = false
        var isAddingParticipant = false
    }

    enum MuteStatus {

        case muted, `default`

        init(from notificationLevel: TCHConversationNotificationLevel) {
            switch notificationLevel {
            case .default:
                self = .default
            case .muted:
                self = .muted
            @unknown default:
                fatalError()
            }
        }
    }

    enum MessageType {

        /// If it is nil, message is sent by the current user
        typealias Identity = String?

        case none
        case media(Identity, MessageStatus)
        case text(String, MessageStatus)

        enum MessageStatus {

            case sent(SendingStatus)
            case received

            enum SendingStatus {

                case sending, sent, delivered
                case error(ErrorType)

                enum ErrorType {
                    case failedToSend, other
                }
            }
        }
    }
}

extension ConversationListCellViewModel: CustomDebugStringConvertible {

    var debugDescription: String {
        "sid: \(sid), name: \(name), lmd: \(lastMessageDate)"
    }
}
