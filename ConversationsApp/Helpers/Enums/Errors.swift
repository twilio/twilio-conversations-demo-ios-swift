//
//  Errors.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

public enum LoginError: Error {

    case allFieldsMustBeFilled
    case unavailable
    case accessDenied
    case couldNotEncodeLoginInput
    case tokenServiceIsNotSupplied
    case tokenServiceUrlIsInvalid
    case unableToStoreCredentials
    case unableToUpdateTokenError
}

extension LoginError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString("Access denied, invalid credentials", comment: "Access denied, invalid credentials")
        case .allFieldsMustBeFilled:
            return NSLocalizedString("All sign in fields must be supplied", comment: "All sign in fields must be supplied")
        case .unavailable:
            return NSLocalizedString("Token service is unavailable", comment: "Token service is unavailable")
        case .couldNotEncodeLoginInput:
            return NSLocalizedString("Could not encode login input", comment: "Could not encode login input")
        case .tokenServiceIsNotSupplied:
            return NSLocalizedString("Token service URL was not supplied", comment: "Token service URL was not supplied")
        case .tokenServiceUrlIsInvalid:
            return NSLocalizedString("Supplied token service URL is invalid", comment: "Supplied token service URL is invalid")
        case .unableToStoreCredentials:
            return NSLocalizedString("Local storage is not able to store credentials", comment: "Local storage is not able to store credentials")
        case .unableToUpdateTokenError:
            return NSLocalizedString("Unable to update the token", comment: "Unable to update the token")
        }
    }
}

public enum DataFetchError: Error {

    case requiredDataCallsFailed
    case conversationsClientIsNotAvailable
    case dataIsInconsistent
}

extension DataFetchError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .requiredDataCallsFailed:
            return NSLocalizedString("An error occured during data load, some information might be missing", comment: "An error occured during data load, some information might be missing")
        case .conversationsClientIsNotAvailable:
            return NSLocalizedString("An error occured during data load, the TwilioConversations SDK client was not available", comment: "An error occured during the data load, the TwilioConversations SDK client was not available")
        case .dataIsInconsistent:
            return NSLocalizedString("The data is inconsistent, try to reload this screen", comment: "An error occured during the data load, data is inconsistent, a screen reload might be needed")
        }
    }
}

enum ActionError: Error {

    case unknown
    case notAbleToRetrieveCachedMessage
    case notAbleToBuildMessage
    case conversationNotAvailable
    case messagesNotAvailable
    case writeToCacheError
}

extension ActionError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return NSLocalizedString("An unknwon error occured", comment: "An unknwon error occured")
        case .notAbleToRetrieveCachedMessage:
            return NSLocalizedString("The message was not found in the local cache", comment: "Could not find the message in local cache")
        case .conversationNotAvailable:
            return NSLocalizedString("The conversation you are trying to use is not available", comment: "Conversation is not available")
        case .messagesNotAvailable:
            return NSLocalizedString("The message list on this conversation is not available", comment: "Message list is not available")
        case .notAbleToBuildMessage:
            return NSLocalizedString("The message you are trying to send could not be converted to a TCHMessage", comment: "Invalid message construction")
        case .writeToCacheError:
            return NSLocalizedString("Could not copy the media to app cache", comment: "Cache error")
        }
    }
}
