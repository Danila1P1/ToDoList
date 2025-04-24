//
//  NetworkService.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import Foundation

protocol INetworkService: AnyObject {
    func fetchRemoteTasks(completion: @escaping (Result<[Task], Error>) -> Void)
}

final class NetworkService: INetworkService {
    
    // MARK: - Public Properties

    enum Error: Swift.Error {
        case noData
    }

    // MARK: - Constructors

    init(dispatchQueue: IDispatchQueueWrapper, urlSessionWrapper: IURLSessionWrapper) {
        self.dispatchQueue = dispatchQueue
        self.urlSessionWrapper = urlSessionWrapper
    }

    // MARK: - Public Methods

    func fetchRemoteTasks(completion: @escaping (Result<[Task], Swift.Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        dispatchQueue.async {
            let request = URLRequest(url: url)
            let task = self.urlSessionWrapper.dataTask(with: request) { data, _, error in
                do {
                    guard let data else {
                        completion(.failure(error ?? Error.noData))
                        return
                    }
                    let decoded = try JSONDecoder().decode(TaskResponse.self, from: data)
                    let tasks = decoded.todos.map { Task(id: Int64($0.id), title: $0.todo, descriptionText: "", isCompleted: $0.completed, createdAt: Date()) }

                    completion(.success(tasks))
                } catch let error {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    // MARK: - Private Properties

    private let dispatchQueue: IDispatchQueueWrapper
    private let urlSessionWrapper: IURLSessionWrapper
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
