//
//  NetworkServiceTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import XCTest
@testable import ToDoList

final class NetworkServiceTests: XCTestCase {

    var mockQueue: MockDispatchQueueWrapper!
    var mockSession: MockURLSessionWrapper!
    var networkService: NetworkService!

    override func setUp() {
        super.setUp()
        mockQueue = MockDispatchQueueWrapper()
        mockSession = MockURLSessionWrapper()
        networkService = NetworkService(dispatchQueue: mockQueue, urlSessionWrapper: mockSession)
    }

    override func tearDown() {
        mockQueue = nil
        mockSession = nil
        networkService = nil
        super.tearDown()
    }

    func testFetchRemoteTasksSuccess() {
        let json = """
        {
            "todos": [
                { "id": 1, "todo": "Test todo", "completed": false }
            ]
        }
        """.data(using: .utf8)

        mockSession.mockData = json
        let expectation = expectation(description: "fetchRemoteTasks")

        networkService.fetchRemoteTasks { result in
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.id, 1)
                XCTAssertEqual(tasks.first?.title, "Test todo")
                XCTAssertEqual(tasks.first?.isCompleted, false)
            case .failure:
                XCTFail("Expected success, got failure")
            }
            expectation.fulfill()
        }

        mockQueue.executePending()

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchRemoteTasksFailureNoData() {
        mockSession.mockData = nil
        let expectation = expectation(description: "fetchRemoteTasks")

        networkService.fetchRemoteTasks { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        mockQueue.executePending()

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchRemoteTasksFailureInvalidJSON() {
        let invalidJson = "{ invalid json ]".data(using: .utf8)
        mockSession.mockData = invalidJson
        let expectation = expectation(description: "fetchRemoteTasks")

        networkService.fetchRemoteTasks { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to decoding error")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }

        mockQueue.executePending()

        wait(for: [expectation], timeout: 1.0)
    }
}
