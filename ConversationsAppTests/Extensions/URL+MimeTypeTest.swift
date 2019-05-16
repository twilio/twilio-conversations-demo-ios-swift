//
//  URL+MimeType.swift
//  ConversationsAppTests
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import XCTest

@testable import ConversationsApp

fileprivate class URLExtensionTest: XCTestCase {

    func testURLMimeType() {
        let testValues = [
            (
                input: "file:///private/var/mobile/Containers/Data/Application/69FA08A6-9E24-4AF4-B50B-EC0E63350166/tmp/773D8FF2-2AE5-4218-AD20-F19308404943.png",
                expected: "image/png"
            ),
            (
                input: "file:///private/var/mobile/Containers/Data/Application/69FA08A6-9E24-4AF4-B50B-EC0E63350166/tmp/773D8FF2-2AE5-4218-AD20-F19308404943.jpg",
                expected: "image/jpeg"
            ),
            (
                input: "file:///private/var/mobile/Containers/Data/Application/69FA08A6-9E24-4AF4-B50B-EC0E63350166/tmp/773D8FF2-2AE5-4218-AD20-F19308404943.jpeg",
                expected: "image/jpeg"
            ),
            (
            input: "file:///private/var/mobile/Containers/Data/Application/69FA08A6-9E24-4AF4-B50B-EC0E63350166/tmp/773D8FF2-2AE5-4218-AD20-F19308404943.xyz",
            expected: nil
            )
        ]

        for testData in testValues {
            let testURL = URL(string: testData.input)
            XCTAssertEqual(testURL!.associatedMimeType, testData.expected)
        }
    }
}
