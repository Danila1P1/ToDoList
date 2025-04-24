//
//  MockCoreDataManager.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import Foundation
@testable import ToDoList

final class MockCoreDataManager: ICoreDataManager {

    var stubbedTasks: [Task] = []
    var stubbedSearchResult: [Task] = []
    var createdTasks: [Task] = []

    func fetchAllTasks(completion: @escaping ([Task]) -> Void) {
        completion(stubbedTasks)
    }

    func create(_ task: Task, completion: @escaping () -> Void) {
        createdTasks.append(task)
        completion()
    }

    func delete(_ task: Task, completion: @escaping () -> Void) {
        if let index = createdTasks.firstIndex(where: { $0.id == task.id }) {
            createdTasks.remove(at: index)
        }
        completion()
    }

    func update(_ task: Task, completion: @escaping () -> Void) {
        if let index = createdTasks.firstIndex(where: { $0.id == task.id }) {
            createdTasks[index] = task
        }
        completion()
    }

    func searchTasks(matching text: String, on queue: DispatchQueue, completion: @escaping ([Task]) -> Void) {
        completion(stubbedSearchResult)
    }
}
