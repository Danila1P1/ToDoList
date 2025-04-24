//
//  TaskModelTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 24.04.2025.
//

import XCTest
@testable import ToDoList

final class TaskModelTests: XCTestCase {

    func testTaskInitialization() {
        let now = Date()
        let task = Task(id: 1, title: "Test", descriptionText: "Desc", isCompleted: false, createdAt: now)

        XCTAssertEqual(task.title, "Test")
        XCTAssertEqual(task.descriptionText, "Desc")
        XCTAssertEqual(task.isCompleted, false)
        XCTAssertEqual(task.createdAt, now)
    }

    func testToggleCompletion() {
        var task = Task(id: 10, title: "Test", descriptionText: "", isCompleted: false, createdAt: Date())
        task.isCompleted.toggle()
        XCTAssertTrue(task.isCompleted)
    }

    func testMappingToAndFromEntity() {
        let task = Task(id: 7, title: "Title", descriptionText: "Text", isCompleted: true, createdAt: Date())
        let entity = TaskEntity(context: CoreDataManager.shared.context)
        entity.configure(with: task)
        let mapped = Task(entity: entity)

        XCTAssertEqual(mapped.id, task.id)
        XCTAssertEqual(mapped.title, task.title)
        XCTAssertEqual(mapped.descriptionText, task.descriptionText)
        XCTAssertEqual(mapped.isCompleted, task.isCompleted)
    }
}
