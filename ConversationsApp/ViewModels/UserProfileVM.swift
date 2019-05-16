//
//  UserProfileVM.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioConversationsClient

class UserProfileViewModel: NSObject {

    // MARK: Properties

    private let conversationsRepository: ConversationsRepositoryProtocol
    var user: TCHUser? {
        conversationsRepository.conversationsProvider.conversationsClient?.user
    }
    weak var delegate: UserProfileViewModelListener?

    // MARK: Init

    init(conversationsRepository: ConversationsRepositoryProtocol = ConversationsRepository.shared) {
        self.conversationsRepository = conversationsRepository
        super.init()
    }

    func updateFriendlyName(_ newName: String) {
        user?.setFriendlyName(newName, completion: { (result) in
            if let error = result.error {
                self.delegate?.onDisplayError(error)
            } else {
                self.delegate?.onFriendlyNameUpdated()
            }
        })
    }
}
