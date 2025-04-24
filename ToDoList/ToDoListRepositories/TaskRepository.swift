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

    func searchTasks(text: String, completion: @escaping ([Task]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = CoreDataManager.shared.searchTasks(matching: text)

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
