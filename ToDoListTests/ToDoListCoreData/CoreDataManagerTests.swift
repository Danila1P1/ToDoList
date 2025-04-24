//
//  CoreDataManagerTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 24.04.2025.
//

import XCTest
@testable import ToDoList

final class CoreDataManagerTests: XCTestCase {

    func testCreateAndFetchTask() {
        let task = Task(id: 100, title: "Create", descriptionText: "Desc", isCompleted: false, createdAt: Date())
        MockCoreDataManager.shared.create(task)

        let expectation = XCTestExpectation(description: "Wait for save")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let allTasks = MockCoreDataManager.shared.fetchAllTasks()
            XCTAssertTrue(allTasks.contains { $0.title == "Create" })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUpdateTask() {
        let task = Task(id: 101, title: "To Update", descriptionText: "Before", isCompleted: false, createdAt: Date())
        MockCoreDataManager.shared.create(task)

        let updatedTask = Task(id: 101, title: "Updated", descriptionText: "After", isCompleted: true, createdAt: task.createdAt)
        MockCoreDataManager.shared.update(updatedTask)

        let expectation = XCTestExpectation(description: "Wait for update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let result = MockCoreDataManager.shared.fetchAllTasks().first { $0.id == 101 }
            XCTAssertEqual(result?.title, "Updated")
            XCTAssertEqual(result?.descriptionText, "After")
            XCTAssertEqual(result?.isCompleted, true)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDeleteTask() {
        let task = Task(id: 102, title: "Delete Me", descriptionText: "Soon", isCompleted: false, createdAt: Date())
        MockCoreDataManager.shared.create(task)
        MockCoreDataManager.shared.delete(task)

        let expectation = XCTestExpectation(description: "Wait for delete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all = MockCoreDataManager.shared.fetchAllTasks()
            XCTAssertFalse(all.contains { $0.id == 102 })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSearchTasks() {
        let result = MockCoreDataManager.shared.searchTasks(matching: "Test")
        XCTAssertNotNil(result)
    }
}
