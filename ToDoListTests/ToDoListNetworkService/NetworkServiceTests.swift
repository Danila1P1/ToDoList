//
//  NetworkServiceTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 24.04.2025.
//

import XCTest
@testable import ToDoList

final class NetworkServiceTests: XCTestCase {

    func testFetchRemoteTasksMocked() {
        let expectation = expectation(description: "Remote tasks")

        MockNetworkService().fetchRemoteTasks { tasks in
            XCTAssertNotNil(tasks)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
