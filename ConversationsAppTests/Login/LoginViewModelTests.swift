//
//  LoginViewModelTests.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import XCTest
@testable import ConversationsApp
import Mockingbird

fileprivate class LoginViewModelTests: XCTestCase {

    // Testable object
    var loginViewModel: LoginViewModel!
    
    // Mocked objects
    var mockLoginManager = mock(LoginManager.self)
    var mockLoginStateObserver = mock(LoginStateObserver.self)
    
    override func setUp() {
        loginViewModel = LoginViewModel(loginManager: mockLoginManager)
        loginViewModel.loginStateObserver = mockLoginStateObserver
    }

    func testSuccessfulLogin() {
        given(mockLoginManager.signIn(identity: any(), password: any(), completion: any())) ~> { identity, password, completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                completion(.success)
            }
        }

        XCTAssertFalse(loginViewModel.isLoading, "Should not be loading")

        let expectation =
            eventually {
                verify(mockLoginStateObserver.onLoadingStateChanged()).wasCalled(2)
            }

        // Perform login
        loginViewModel.signIn(identity: "identity", password: "password")

        // Checking state
        XCTAssertTrue(loginViewModel.isLoading, "Loading state should be loading")

        wait(for: [expectation], timeout: 1.0)

        // Checking state
        verify(mockLoginStateObserver.onSignInSucceeded()).wasCalled()
        XCTAssertFalse(loginViewModel.isLoading, "Loading state should not be loading")
        verify(mockLoginStateObserver.onLoadingStateChanged()).wasCalled(2)
        verify(mockLoginStateObserver.onSignInFailed(error: any())).wasNeverCalled()
    }
}
