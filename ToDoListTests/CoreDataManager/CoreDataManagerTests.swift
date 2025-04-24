//
//  CoreDataManagerTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class CoreDataManagerTests: XCTestCase {

    var sut: CoreDataManager!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()

        let container = NSPersistentContainer(name: "ToDoList")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        let expectation = expectation(description: "PersistentStore loaded")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        sut = CoreDataManager(persistentContainer: container)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCreateTaskAndFetchAllTasksShouldContainCreatedTask() {
        let task = Task(id: 1, title: "Test", descriptionText: "Description", isCompleted: false, createdAt: Date())

        let exp = expectation(description: "Create and fetch")

        sut.create(task) {
            self.sut.fetchAllTasks { tasks in
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.title, "Test")
                XCTAssertEqual(tasks.first?.descriptionText, "Description")
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func testDeleteTaskShouldRemoveFromStorage() {
        let task = Task(id: 10, title: "To Delete", descriptionText: "temp", isCompleted: false, createdAt: Date())
        let exp = expectation(description: "Create & delete")

        sut.create(task) {
            self.sut.delete(task) {
                self.sut.fetchAllTasks { tasks in
                    XCTAssertTrue(tasks.isEmpty)
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func testUpdateTaskShouldModifyEntity() {
        let original = Task(id: 3, title: "Old", descriptionText: "desc", isCompleted: false, createdAt: Date())
        var updated = original
        updated.title = "Updated"
        updated.isCompleted = true

        let exp = expectation(description: "Create & update")

        sut.create(original) {
            self.sut.update(updated) {
                self.sut.fetchAllTasks { tasks in
                    XCTAssertEqual(tasks.count, 1)
                    XCTAssertEqual(tasks.first?.title, "Updated")
                    XCTAssertTrue(tasks.first?.isCompleted ?? false)
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func testSearchTasksShouldReturnMatchingTasks() {
        let tasks = [
            Task(id: 1, title: "Buy milk", descriptionText: "From the store", isCompleted: false, createdAt: Date()),
            Task(id: 2, title: "Call mom", descriptionText: "Important!", isCompleted: false, createdAt: Date()),
            Task(id: 3, title: "Read", descriptionText: "Book about CoreData", isCompleted: false, createdAt: Date())
        ]

        let exp = expectation(description: "Search")
        let queue = DispatchQueue(label: "TestQueue")

        let group = DispatchGroup()
        tasks.forEach {
            group.enter()
            sut.create($0) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.sut.searchTasks(matching: "milk", on: queue) { result in
                XCTAssertEqual(result.count, 1)
                XCTAssertEqual(result.first?.title, "Buy milk")
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
}
