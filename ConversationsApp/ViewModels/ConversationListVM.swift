//
//  ConversationListVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class ConversationListViewModel: NSObject {

    // MARK: Properties

    private let conversationsRepository: ConversationsRepositoryProtocol
    private let conversationListManager: ConversationListManagerProtocol

    private var conversationList: ObservableFetchRequestResult<PersistentConversationDataItem>?

    private var conversationCellViewModelMap: [String: ConversationListCellViewModel] = [:]
    private var conversationCellViewModelList: [ConversationListCellViewModel] = []

    private(set) var presentedConversations: [ConversationListCellViewModel] = []

    public weak var delegate: ConversationListObserver?

    var searchQuery: String? {
        didSet {
            updateFilteredList()
        }
    }

    var isSearchQueryActive: Bool {
        guard let searchQuery = searchQuery, !searchQuery.isEmpty else {
            return false
        }

        return true
    }

    var isConversationListLoading: Bool {
        switch conversationFetchStatus {
        case .notStarted, .completed:
            return false
        default:
            return true
        }
    }

    private var conversationFetchStatus = RepositoryFetchStatus.notStarted {
        didSet {
            processFetchStatus(conversationFetchStatus)
        }
    }

    // MARK: Intialization

    init(conversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared,
         conversationListManager: ConversationListManagerProtocol = ConversationListManager()) {
        self.conversationsRepository = conversationsRepository
        self.conversationListManager = conversationListManager
        super.init()

        self.conversationsRepository.listener = self

        loadConversationList()
        listenForConversationListChanges()
    }

    // MARK: Deintialization

    deinit {
        unsubscribeFromConversationListChanges()
    }

    // MARK: Functions

    func createAndJoinConversation(friendlyName: String?, completion: ((Error?) -> Void)?) {
        conversationListManager.createAndJoinConversation(friendlyName: friendlyName) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            completion?(error)
        }
    }

    func reloadConversationList() {
        loadConversationList()
        listenForConversationListChanges()
    }

    func getConversationSidToNavigateTo() -> String? {
        return conversationsRepository.getConversationSidToNavigateTo()
    }

    private func processFetchStatus(_ status: RepositoryFetchStatus) {
        switch status {
        case .error(let error):
            delegate?.onDisplayError(error)
        case .completed:
            delegate?.onDataChanged()
        default:
            break
        }
    }

    private func loadConversationList() {
        self.conversationsRepository.clearConversationList()
        conversationList?.removeObserver(self) // remove observer if it was set previously
        conversationList = getConversationList()
    }

    private func getConversationList() -> ObservableFetchRequestResult<PersistentConversationDataItem> {
        let resultHandle = conversationsRepository.getConversationList()
        resultHandle.requestStatus.observe(with: self) { requestStatus in
            guard let requestStatus = requestStatus else {
                return
            }

            self.conversationFetchStatus = requestStatus
        }
        return resultHandle.data
    }

    private func updateConversationCellViewModels(items: [ConversationDataItem]) {
        var viewModelList = createConversationCellViewModels(from: items)

        // Sort list
        viewModelList.sort { $0.lastMessageDate > $1.lastMessageDate }

        // Create map for easy access
        let viewModelMap = viewModelList.reduce(into: [:]) { result, item in
            result[item.sid] = item
        }

        conversationCellViewModelMap = viewModelMap
        conversationCellViewModelList = viewModelList
        updateFilteredList()
    }

    private func createConversationCellViewModels(from items: [ConversationDataItem]) -> [ConversationListCellViewModel] {
        let createdCellViewModels: [ConversationListCellViewModel] = items.compactMap {
            let cell = ConversationListCellViewModel(item: $0)
            cell?.delegate = self
            return cell
        }

        // Grabbing and setting user interaction state from previous displayed cells, if possible
        let oldCells = conversationCellViewModelMap
        for cellViewModel in createdCellViewModels {
            guard let oldCell = oldCells[cellViewModel.sid] else {
                continue
            }
            cellViewModel.userInteractionState = oldCell.userInteractionState
        }

        return createdCellViewModels
    }

    func getConversationCellViewModel(at: Int) -> ConversationListCellViewModel? {
        guard at >= 0 else {
            return nil
        }

        guard at < presentedConversations.count else {
            return nil
        }
        return presentedConversations[at]
    }

    func getConversationCellViewModel(by sid: String) -> ConversationListCellViewModel? {
        return conversationCellViewModelMap[sid]
    }

    private func listenForConversationListChanges() {
        conversationList?.observe(with: self, { [weak self] list in
            self?.updateConversationCellViewModels(items: list?.compactMap { $0.getConversationDataItem() } ?? [])
        })
    }

    private func unsubscribeFromConversationListChanges() {
        conversationList?.removeObserver(self)
    }

    private func updateFilteredList() {
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            presentedConversations = conversationCellViewModelList.filter { $0.name.range(of: searchQuery, options: .caseInsensitive) != nil }
        } else {
            presentedConversations = conversationCellViewModelList
        }
        delegate?.onDataChanged()
    }
}

extension ConversationListViewModel: ConversationListActionListener {

    func onSetConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel) {
        conversationCellViewModelMap[sid]?.userInteractionState.isChangingNotificationLevel = true
        conversationListManager.setConversationNotificationLevel(sid: sid, level: level) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.conversationCellViewModelMap[sid]?.userInteractionState.isChangingNotificationLevel = false
        }
    }

    func onLeaveConversation(sid: String) {
        conversationCellViewModelMap[sid]?.userInteractionState.isLeavingConversation = true
        conversationListManager.leaveConversation(sid: sid) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.conversationCellViewModelMap[sid]?.userInteractionState.isLeavingConversation = false
        }
    }

    func onAddParticipant(participantIdentity: String, conversationSid: String) {
        conversationCellViewModelMap[conversationSid]?.userInteractionState.isAddingParticipant = true
        conversationListManager.addParticipant(identity: participantIdentity, sid: conversationSid) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.conversationCellViewModelMap[conversationSid]?.userInteractionState.isAddingParticipant = false
        }
    }

    func onJoinConversation(with id: String) {
        conversationCellViewModelMap[id]?.userInteractionState.isJoining.value = true
        conversationListManager.joinConversation(id) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.conversationCellViewModelMap[id]?.userInteractionState.isJoining.value = false
        }
    }
}

extension ConversationListViewModel: ConversationsRepositoryListenerProtocol {
    func onErrorOccured(_ error: Error) {
        delegate?.onDisplayError(error)
    }

    func pushNotificationTapped() {
        delegate?.onNotificationTap()
    }
}
