//
//  TokenWrapperProtocol.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

protocol TokenWrapper: AnyObject {

    static func getTokenUrlFromEnv(identity: String, password: String) -> URL?
    static func getTokenUrlFromDefaults(identity: String, password: String) -> URL?
    static func getConversationsAccessToken(identity: String, password: String, completion: @escaping (Result<String, LoginError>) -> Void)
    static func buildGetAccessTokenOperation(username: String, password: String) -> AsyncOperation<Credentials, String>
}
