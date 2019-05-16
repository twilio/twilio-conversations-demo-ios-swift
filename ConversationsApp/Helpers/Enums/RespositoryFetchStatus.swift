//
//  RespositoryFetchStatus.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

enum RepositoryFetchStatus {

    case notStarted
    case fetching
    case subscribing
    case completed
    case error(Error)
}
