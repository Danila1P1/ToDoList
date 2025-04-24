//
//  CoreDataManagerTests.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import XCTest
@testable import ToDoList
import CoreData

final class CoreDataManagerTests: XCTestCase {
    
    var mockCoreDataManager: MockCoreDataManager!
    var mockContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        mockCoreDataManager = MockCoreDataManager()
        mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    override func tearDown() {
        mockCoreDataManager = nil
        mockContext = nil
        super.tearDown()
    }
    
    func testFetchAllTasksShouldReturnCorrectTasks() {
        let task = Task(id: 1, title: "Test Task", descriptionText: "Description", isCompleted: false, createdAt: Date())
        mockCoreDataManager.stubbedTasks = [task]
        
        let exp = expectation(description: "Fetch all tasks")
        mockCoreDataManager.fetchAllTasks { tasks in
            XCTAssertEqual(tasks.count, 1)
            XCTAssertEqual(tasks.first?.title, "Test Task")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testCreateShouldAddTaskToCoreData() {
        let task = Task(id: 2, title: "Create Task", descriptionText: "", isCompleted: false, createdAt: Date())
        
        mockCoreDataManager.create(task) {
            XCTAssertTrue(self.mockCoreDataManager.createdTasks.contains { $0.id == task.id })
        }
    }
    
    func testDeleteShouldRemoveTaskFromCoreData() {
        let task = Task(id: 3, title: "Delete Me", descriptionText: "", isCompleted: false, createdAt: Date())
        mockCoreDataManager.createdTasks.append(task)
        
        mockCoreDataManager.delete(task) {
            XCTAssertFalse(self.mockCoreDataManager.createdTasks.contains { $0.id == task.id })
        }
    }
    
    func testUpdateShouldUpdateTaskInCoreData() {
        var task = Task(id: 4, title: "Update Me", descriptionText: "Old Description", isCompleted: false, createdAt: Date())
        mockCoreDataManager.createdTasks.append(task)
        
        task.descriptionText = "Updated Description"
        
        mockCoreDataManager.update(task) {
            XCTAssertEqual(self.mockCoreDataManager.createdTasks.first { $0.id == task.id }?.descriptionText, "Updated Description")
        }
    }
    
    func testSearchTasksShouldReturnCorrectResults() {
        let task1 = Task(id: 5, title: "Search Task 1", descriptionText: "Desc 1", isCompleted: false, createdAt: Date())
        let task2 = Task(id: 6, title: "Search Task 2", descriptionText: "Desc 2", isCompleted: true, createdAt: Date())
        mockCoreDataManager.stubbedSearchResult = [task1, task2]
        
        let exp = expectation(description: "Search tasks")
        mockCoreDataManager.searchTasks(matching: "Search Task", on: DispatchQueue.main) { tasks in
            XCTAssertEqual(tasks.count, 2)
            XCTAssertEqual(tasks.first?.title, "Search Task 1")
            XCTAssertEqual(tasks.last?.title, "Search Task 2")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
