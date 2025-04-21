//
//  TaskRepository.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import Foundation

final class TaskRepository {

    // MARK: - Public Methods

    func loadTasks(completion: @escaping ([Task]) -> Void) {
        let coreTasks = CoreDataManager.shared.fetchAllTasks()

        if coreTasks.isEmpty {
            NetworkService().fetchRemoteTasks { tasks in
                tasks.forEach { task in
                    CoreDataManager.shared.create(task)
                }
                completion(tasks)
            }
        } else {
            completion(coreTasks)
        }
    }
}
