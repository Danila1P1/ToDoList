//
//  TaskMappingTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class TaskMappingTests: XCTestCase {

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "ToDoList")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        let exp = expectation(description: "Load persistent stores")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        context = container.viewContext
    }

    func testTaskInitFromEntityShouldCreateCorrectTask() {
        let entity = TaskEntity(context: context)
        entity.id = 101
        entity.title = "Title"
        entity.descriptionText = "Desc"
        entity.isCompleted = true
        entity.createdAt = Date(timeIntervalSince1970: 999)

        let task = Task(entity: entity)

        XCTAssertEqual(task.id, 101)
        XCTAssertEqual(task.title, "Title")
        XCTAssertEqual(task.descriptionText, "Desc")
        XCTAssertTrue(task.isCompleted)
        XCTAssertEqual(task.createdAt, Date(timeIntervalSince1970: 999))
    }

    func testTaskInitFromEntityWithNilValuesShouldUseDefaults() {
        let entity = TaskEntity(context: context)
        entity.id = 1

        let task = Task(entity: entity)

        XCTAssertEqual(task.id, 1)
        XCTAssertEqual(task.title, "")
        XCTAssertEqual(task.descriptionText, "")
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.createdAt)
    }

    func testTaskEntityConfigureShouldSetAllValues() {
        let task = Task(
            id: 202,
            title: "Configured Task",
            descriptionText: "From model",
            isCompleted: true,
            createdAt: Date(timeIntervalSince1970: 1234)
        )
        let entity = TaskEntity(context: context)

        entity.configure(with: task)

        XCTAssertEqual(entity.id, 202)
        XCTAssertEqual(entity.title, "Configured Task")
        XCTAssertEqual(entity.descriptionText, "From model")
        XCTAssertTrue(entity.isCompleted)
        XCTAssertEqual(entity.createdAt, Date(timeIntervalSince1970: 1234))
    }
}
