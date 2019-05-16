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
    private(set) var userConversationList: ObservableFetchRequestResult<PersistentConversationDataItem>?
    private(set) var publicConversationList: ObservableFetchRequestResult<PersistentConversationDataItem>?
    private(set) var filteredConversations: [ConversationListCellViewModel] = []
    private(set) var userConversationCellViewModelMap: [String: ConversationListCellViewModel] = [:]
    private(set) var publicConversationCellViewModelMap: [String: ConversationListCellViewModel] = [:]
    public weak var delegate: ConversationListObserver?

    private let conversationListOrder: (ConversationListCellViewModel, ConversationListCellViewModel) -> (Bool) = { first, second in
        return first.lastMessageDate > second.lastMessageDate
    }

    private(set) var orderedConversationCellViewModels = [ConversationListCellViewModel]() {
        didSet {
            updateVisibleList()
        }
    }

    private var searchQuery: String? {
        didSet {
            let displayedList = getDisplayedConversationList()
            if let searchQuery = searchQuery, !searchQuery.isEmpty {
                filteredConversations = displayedList.filter { $0.friendlyName.range(of: searchQuery, options: .caseInsensitive) != nil }
            } else {
                filteredConversations = displayedList
            }
            delegate?.onDataChanged()
        }
    }

    private var conversationFetchStatus = RepositoryFetchStatus.notStarted {
        didSet {
            processFetchStatus(conversationFetchStatus)
        }
    }

    // MARK: Intialization

    init(conversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared, conversationListManager: ConversationListManagerProtocol = ConversationListManager()) {
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

    func createAndJoinConversation(friendlyName: String?) {
        conversationListManager.createAndJoinConversation(friendlyName: friendlyName) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
        }
    }

    func reloadConversationList() {
        self.loadConversationList()
        self.listenForConversationListChanges()
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
        userConversationList = getConversationList()
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

    func getDisplayedConversationList() -> [ConversationListCellViewModel] {
        return orderedConversationCellViewModels
    }

    private func updateConversationCellViewModels(items: [ConversationDataItem]) {
        var viewModelList = createConversationCellViewModels(from: items)

        // Sort list
        viewModelList.sort(by: conversationListOrder)

        // Create map for easy access
        var viewModelMap: [String: ConversationListCellViewModel] = [:]
        viewModelList.forEach {
            viewModelMap[$0.sid] = $0
            viewModelMap[$0.uniqueName] = $0
        }

        userConversationCellViewModelMap = viewModelMap
        orderedConversationCellViewModels = viewModelList
    }

    private func createConversationCellViewModels(from items: [ConversationDataItem]) -> [ConversationListCellViewModel] {
        let createdCellViewModels: [ConversationListCellViewModel] = items.compactMap {
            let cell = ConversationListCellViewModel(item: $0)
            cell?.delegate = self
            return cell
        }

        // Grabbing and setting user interaction state from previous displayed cells, if possible
        let oldCells = userConversationCellViewModelMap
        for cellViewModel in createdCellViewModels {
            guard let oldCell = oldCells[cellViewModel.sid] else {
                continue
            }
            cellViewModel.userInteractionState = oldCell.userInteractionState
        }

        return createdCellViewModels
    }

    private func getConversationCellViewModel(at: Int) -> ConversationListCellViewModel? {
        guard at >= 0 else {
            return nil
        }

        guard at < orderedConversationCellViewModels.count else {
            return nil
        }
        return orderedConversationCellViewModels[at]
    }

    private func listenForConversationListChanges() {
        userConversationList?.observe(with: self, { [weak self] list in
            self?.updateConversationCellViewModels(items: list?.compactMap { $0.getConversationDataItem() } ?? [])
        })
    }

    private func unsubscribeFromConversationListChanges() {
        userConversationList?.removeObserver(self)
        publicConversationList?.removeObserver(self)
    }

    private func isConversationListLoading() -> Bool {
        let checkStatus: (RepositoryFetchStatus) -> (Bool) = { fetchStatus in
            switch fetchStatus {
            case .notStarted, .completed:
                return false
            default:
                return true
            }
        }

        return checkStatus(conversationFetchStatus)
    }

    private func updateVisibleList() {
        if isSearchQueryActive() {
            searchConversationList(contains: searchQuery)
        } else {
            delegate?.onDataChanged()
        }
    }

    private func isSearchQueryActive() -> Bool {
        guard let searchQuery = self.searchQuery, !searchQuery.isEmpty else {
            return false
        }

        return true
    }

    func searchConversationList(contains: String?) {
        searchQuery = contains
    }

    func getDisplayedConversationAt(index: Int) -> ConversationListCellViewModel {
        let list = getDisplayedConversationList()
        return list[index]
    }

    func signOut() {
        try? ConversationsCredentialStorage.shared.deleteCredentials()
        delegate?.onLogout()
    }
}

extension ConversationListViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isConversationListLoading() {
            return 1
        } else if isSearchQueryActive() {
            return filteredConversations.count
        }

        return getDisplayedConversationList().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isConversationListLoading(),
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingConversationListCell") as? LoadingConversationListCell {
            loadingCell.startLoading()
            return loadingCell
        }

        guard getDisplayedConversationList().count > 0 else {
            return UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
        }

        let conversationCellViewModel: ConversationListCellViewModel
        if isSearchQueryActive() {
            conversationCellViewModel = filteredConversations[indexPath.row]
        } else {
            guard let retrievedCell = getConversationCellViewModel(at: indexPath.row) else {
                return UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
            }
            conversationCellViewModel = retrievedCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedConversationCell") as! JoinedConversationListCell
        cell.setup(with: conversationCellViewModel)
        return cell
    }
}

extension ConversationListViewModel: ConversationListActionListener {
    func onSetConversationNotificationLevel(sid: String, level: TCHConversationNotificationLevel) {
        userConversationCellViewModelMap[sid]?.userInteractionState.isChangingNotificationLevel = true
        publicConversationCellViewModelMap[sid]?.userInteractionState.isChangingNotificationLevel = true
        conversationListManager.setConversationNotificationLevel(sid: sid, level: level) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.userConversationCellViewModelMap[sid]?.userInteractionState.isChangingNotificationLevel = false
            self.publicConversationCellViewModelMap[sid]?.userInteractionState.isChangingNotificationLevel = false
        }
    }

    func onDestroyConversation(sid: String) {
        userConversationCellViewModelMap[sid]?.userInteractionState.isDestroyingConversation = true
        publicConversationCellViewModelMap[sid]?.userInteractionState.isDestroyingConversation = true
        conversationListManager.destroyConversation(sid: sid) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.userConversationCellViewModelMap[sid]?.userInteractionState.isDestroyingConversation = false
            self.publicConversationCellViewModelMap[sid]?.userInteractionState.isDestroyingConversation = false
        }
    }

    func onAddParticipant(participantIdentity: String, conversationSid: String) {
        userConversationCellViewModelMap[conversationSid]?.userInteractionState.isAddingParticipant = true
        publicConversationCellViewModelMap[conversationSid]?.userInteractionState.isAddingParticipant = true
        conversationListManager.addParticipant(identity: participantIdentity, sid: conversationSid) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.userConversationCellViewModelMap[conversationSid]?.userInteractionState.isAddingParticipant = false
            self.publicConversationCellViewModelMap[conversationSid]?.userInteractionState.isAddingParticipant = false
        }
    }

    func onJoinConversation(sid: String) {
        userConversationCellViewModelMap[sid]?.userInteractionState.isJoining.value = true
        publicConversationCellViewModelMap[sid]?.userInteractionState.isJoining.value = true
        conversationListManager.joinConversation(sid) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.userConversationCellViewModelMap[sid]?.userInteractionState.isJoining.value = false
            self.publicConversationCellViewModelMap[sid]?.userInteractionState.isJoining.value = false
        }
    }

    func onJoinConversation(uniqueName: String) {
        userConversationCellViewModelMap[uniqueName]?.userInteractionState.isJoining.value = true
        publicConversationCellViewModelMap[uniqueName]?.userInteractionState.isJoining.value = true
        conversationListManager.joinConversation(uniqueName) { (error) in
            if let error = error {
                self.delegate?.onDisplayError(error)
            }
            self.userConversationCellViewModelMap[uniqueName]?.userInteractionState.isJoining.value = false
            self.publicConversationCellViewModelMap[uniqueName]?.userInteractionState.isJoining.value = false
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
