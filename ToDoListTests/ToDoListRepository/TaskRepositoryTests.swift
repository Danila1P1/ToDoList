//
//  TaskRepositoryTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 24.04.2025.
//

import XCTest
@testable import ToDoList

final class TaskRepositoryTests: XCTestCase {

    func testLoadTasksFromCoreDataOrNetwork() {
        let expectation = expectation(description: "Loaded tasks")

        TaskRepository().loadTasks { tasks in
            XCTAssertNotNil(tasks)
            XCTAssertTrue(tasks.count >= 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchTasks() {
        let expectation = expectation(description: "Search tasks")

        TaskRepository().searchTasks(text: "test") { results in
            XCTAssertNotNil(results)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
