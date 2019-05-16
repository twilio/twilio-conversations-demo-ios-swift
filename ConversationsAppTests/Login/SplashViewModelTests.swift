//
//  SplashViewModelTests.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import XCTest
@testable import ConversationsApp
import Mockingbird

fileprivate class SplashViewModelTests: XCTestCase {
    // Testable object
    var splashViewModel: SplashViewModel!

    // Mocked objects
    var mockLoginManager = mock(LoginManager.self)
    var mockSplashStateObserver = mock(SplashStateObserver.self)
    var credentialStorage = ConversationsCredentialStorage.shared

    override func setUp() {
        splashViewModel = SplashViewModel(loginManager: mockLoginManager, credentialStorage: credentialStorage)
        splashViewModel.splashStateObserver = mockSplashStateObserver
    }

    func testSuccessfulLogin() {
        XCTAssertFalse(splashViewModel.retryVisible, "Retry should not be visible")
        XCTAssertFalse(splashViewModel.signOutVisible, "signOut should not be visible")
        XCTAssertEqual(splashViewModel.status, SplashScreenStatus.idle, "splashViewModel should be idle")

        given(mockLoginManager.signInUsingStoredCredentials(completion: any())) ~> { completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                completion(.success)
            }
        }

        let expectation =
            eventually {
                verify(mockSplashStateObserver.onStatusChanged()).wasCalled(2)
            }

        // Perform login
        splashViewModel.signIn()

        XCTAssertEqual(splashViewModel.status, SplashScreenStatus.connecting, "splashViewModel should be connecting")

        wait(for: [expectation], timeout: 1)

        // Checking state
        XCTAssertFalse(splashViewModel.retryVisible, "Retry should not be visible")
        XCTAssertFalse(splashViewModel.signOutVisible, "signOut should not be visible")
        XCTAssertEqual(splashViewModel.status, SplashScreenStatus.idle, "splashViewModel should be idle")
        verify(mockSplashStateObserver.onShowConversationListScreen()).wasCalled()
        verify(mockSplashStateObserver.onDisplayError(any(), onAcknowledged: any())).wasNeverCalled()
        verify(mockSplashStateObserver.onShowLoginScreen()).wasNeverCalled()
    }

    func testFailedLoginAccessDenied() {
        given(mockLoginManager.signInUsingStoredCredentials(completion: any())) ~> { completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                completion(.failure(LoginError.accessDenied))
            }
        }
        given(mockSplashStateObserver.onDisplayError(any(), onAcknowledged: any())) ~> { error, completion in
            completion?()
        }

        // Perform login
        splashViewModel.signIn()
        XCTAssertEqual(splashViewModel.status, SplashScreenStatus.connecting, "splashViewModel should be connecting")

        let expectation =
            eventually {
                verify(mockSplashStateObserver.onStatusChanged()).wasCalled(2)
            }

        wait(for: [expectation], timeout: 1)

        // Checking state
        XCTAssertFalse(splashViewModel.retryVisible, "Retry should not be visible")
        XCTAssertFalse(splashViewModel.signOutVisible, "signOut should not be visible")
        XCTAssertEqual(splashViewModel.status, SplashScreenStatus.idle, "splashViewModel should be idle")
        verify(mockSplashStateObserver.onShowConversationListScreen()).wasNeverCalled()
        verify(mockSplashStateObserver.onDisplayError(any(), onAcknowledged: any())).wasCalled()
        verify(mockSplashStateObserver.onShowLoginScreen()).wasCalled()
    }

    func testFailedLoginConnectionError() {
        given(mockLoginManager.signInUsingStoredCredentials(completion: any())) ~> { completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                completion(.failure(LoginError.unavailable))
            }
        }
        given(mockSplashStateObserver.onDisplayError(any(), onAcknowledged: any())) ~> { error, completion in
            completion?()
        }

        // Perform login
        splashViewModel.signIn()

        let expectation =
            eventually {
                verify(mockSplashStateObserver.onStatusChanged()).wasCalled(2)
            }

        XCTAssertEqual(splashViewModel.status, SplashScreenStatus.connecting, "splashViewModel should be connecting")

        wait(for: [expectation], timeout: 1)

        // Checking state
        XCTAssertTrue(splashViewModel.retryVisible, "Retry should be visible")
        XCTAssertTrue(splashViewModel.signOutVisible, "signOut should be visible")
        XCTAssertEqual(splashViewModel.status, SplashScreenStatus.idle, "splashViewModel should be idle")
        verify(mockSplashStateObserver.onShowConversationListScreen()).wasNeverCalled()
        verify(mockSplashStateObserver.onDisplayError(any(), onAcknowledged: any())).wasCalled()
        verify(mockSplashStateObserver.onShowLoginScreen()).wasNeverCalled()
    }

    func testSignOut() {
        // Prepare for test
        try? credentialStorage.saveCredentials(identity: "", password: "")
        XCTAssertTrue(credentialStorage.credentialsExist(identity: "", password: ""))

        // Perform signout
        splashViewModel.signOut()

        // Checking state
        XCTAssertFalse(credentialStorage.credentialsExist(identity: "", password: ""))
        verify(mockSplashStateObserver.onShowLoginScreen()).wasCalled()
        verify(mockSplashStateObserver.onShowConversationListScreen()).wasNeverCalled()
    }
}

