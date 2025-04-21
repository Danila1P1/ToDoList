//
//  NetworkService.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import Foundation

final class NetworkService {
    
    // MARK: - Public Methods

    func fetchRemoteTasks(completion: @escaping ([Task]) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            let decoded = try? JSONDecoder().decode(TaskResponse.self, from: data)
            let tasks = decoded?.todos.map { Task(id: Int64($0.id), title: $0.todo, descriptionText: "", isCompleted: $0.completed, createdAt: Date()) } ?? []
            DispatchQueue.main.async {
                completion(tasks)
            }
        }.resume()
    }
}

// MARK: - Decoding models

private struct TaskResponse: Decodable {
    let todos: [RemoteTask]
}

private struct RemoteTask: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}
