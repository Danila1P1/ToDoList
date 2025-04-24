//
//  NetworkService.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import Foundation

class NetworkService {

    // MARK: - Public Methods

    func fetchRemoteTasks(completion: @escaping ([Task]) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            let decoded = try? JSONDecoder().decode(TaskResponse.self, from: data)
            let tasks = decoded?.todos.map { Task(id: Int64($0.id), title: $0.todo, descriptionText: "", isCompleted: $0.completed, createdAt: Date()) } ?? []

            DispatchQueue.main.async {
                completion(tasks)
            }
        }
    }
}

// MARK: - Decoding models

private struct TaskResponse: Decodable {
    let todos: [RemoteTask]
}

private struct RemoteTask: Decodable {
    let id: Int64
    let todo: String
    let completed: Bool
}
