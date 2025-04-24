//
//  TaskRepositoryTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import XCTest
@testable import ToDoList

final class TaskRepositoryTests: XCTestCase {

    var mockCoreDataManager: MockCoreDataManager!
    var mockNetworkService: MockNetworkService!
    var mockQueue: MockDispatchQueueWrapper!
    var repository: TaskRepository!

    override func setUp() {
        super.setUp()
        mockCoreDataManager = MockCoreDataManager()
        mockNetworkService = MockNetworkService()
        mockQueue = MockDispatchQueueWrapper()

        UserDefaults.standard.removeObject(forKey: "isFirstLaunch")

        repository = TaskRepository(
            coreDataManager: mockCoreDataManager,
            networkService: mockNetworkService,
            dispatchQueueWrapper: mockQueue
        )
    }

    override func tearDown() {
        mockCoreDataManager = nil
        mockNetworkService = nil
        mockQueue = nil
        repository = nil
        super.tearDown()
    }

    func testLoadTasksWhenCoreDataHasTasksShouldReturnThem() {
        let localTasks = [Task(id: 1, title: "Local", descriptionText: "", isCompleted: false, createdAt: Date())]
        mockCoreDataManager.stubbedTasks = localTasks

        let expectation = expectation(description: "loadTasks")

        repository.loadTasks { result in
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.title, "Local")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadTasksWhenFirstLaunchShouldFetchFromNetworkAndSave() {
        mockCoreDataManager.stubbedTasks = []
        mockNetworkService.stubbedTasks = [
            Task(id: 100, title: "Remote", descriptionText: "", isCompleted: true, createdAt: Date())
        ]

        let expectation = expectation(description: "loadTasks from network")

        repository.loadTasks { result in
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.title, "Remote")
            XCTAssertTrue(self.mockCoreDataManager.createdTasks.contains { $0.title == "Remote" })
            XCTAssertTrue(UserDefaults.standard.bool(forKey: "isFirstLaunch"))
            expectation.fulfill()
        }

        mockQueue.executePending()
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadTasksWhenNetworkFailsShouldReturnEmpty() {
        mockCoreDataManager.stubbedTasks = []
        mockNetworkService.shouldFail = true

        let expectation = expectation(description: "loadTasks failure")

        repository.loadTasks { result in
            XCTAssertTrue(result.isEmpty)
            expectation.fulfill()
        }

        mockQueue.executePending()
        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchTasksShouldCallCoreDataSearch() {
        let tasks = [
            Task(id: 1, title: "Test Search", descriptionText: "desc", isCompleted: false, createdAt: Date())
        ]
        mockCoreDataManager.stubbedSearchResult = tasks

        let expectation = expectation(description: "searchTasks")

        repository.searchTasks(text: "Test") { result in
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.title, "Test Search")
            expectation.fulfill()
        }

        mockQueue.executePending()
        wait(for: [expectation], timeout: 1.0)
    }
}
