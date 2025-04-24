//
//  MockNetworkService.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import Foundation
@testable import ToDoList

final class MockNetworkService: INetworkService {

    var stubbedTasks: [Task] = []
    var shouldFail: Bool = false

    func fetchRemoteTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "Mock", code: 1)))
        } else {
            completion(.success(stubbedTasks))
        }
    }
}
