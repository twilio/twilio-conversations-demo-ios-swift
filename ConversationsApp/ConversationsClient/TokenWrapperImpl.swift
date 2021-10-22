//
//  TokenWrapperImpl.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation

extension TokenWrapper {

    private static func constructLoginUrl(_ url: String, identity: String, password: String) -> URL? {
        guard var urlComponents = URLComponents(string: url) else {
            return nil
        }

        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        queryItems.append(URLQueryItem(name: "identity", value: identity))
        queryItems.append(URLQueryItem(name: "password", value: password))

        urlComponents.queryItems = queryItems

        return urlComponents.url
    }

    static func getTokenUrlFromEnv(identity: String, password: String) -> URL? {
        guard let tokenServiceUrl = ProcessInfo.processInfo.environment["ACCESS_TOKEN_SERVICE_URL"] else {
            return nil
        }
        return constructLoginUrl(tokenServiceUrl, identity: identity, password: password)
    }

    static func getTokenUrlFromDefaults(identity: String, password: String) -> URL? {
        // Get token service absolute URL from settings
        guard let tokenServiceUrl = UserDefaults.standard.string(forKey: "ACCESS_TOKEN_SERVICE_URL") else {
            return nil
        }
        return constructLoginUrl(tokenServiceUrl, identity: identity, password: password)
    }

    static func getConversationsAccessToken(identity: String, password: String, completion: @escaping (Result<String, LoginError>) -> Void) {
        let requestUrl: URL

        if let url = getTokenUrlFromEnv(identity: identity, password: password) {
            requestUrl = url
        } else if let url = getTokenUrlFromDefaults(identity: identity, password: password) {
            requestUrl = url
        } else {
            completion(.failure(.tokenServiceUrlIsInvalid))
            return
        }

        // Make a request
        let request = URLRequest(url: requestUrl)

        // Getting conversations token from token service
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(.unavailable))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.unavailable))
                return
            }

            if response.statusCode == 401 {
                completion(.failure(.accessDenied))
                return
            }

            guard let data = data, let token = String(data: data, encoding: .utf8) else {
                completion(.failure(.unavailable))
                return
            }

            print("TOKEN: \(token)")
            completion(.success(token))
        }.resume()
    }

    static func buildGetAccessTokenOperation(username: String, password: String) -> AsyncOperation<Credentials, String> {
        return AsyncOperation(
            input: Credentials(username: username, password: password),
            task: { input, callback in
                self.getConversationsAccessToken(identity: input.username, password: input.password) { result in
                    switch result {
                    case .failure(let error):
                        callback(.failure(error))
                    case.success(let token):
                        callback(.success(token))
                    }
                }
            })
    }
}

class TokenWrapperImpl: TokenWrapper {}
