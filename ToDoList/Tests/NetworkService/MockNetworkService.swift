//
//  MockNetworkService.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 24.04.2025.
//

import Foundation
@testable import ToDoList

final class MockNetworkService: NetworkService {
    
    var shouldReturnError: Bool = false
    var mockTasks: [Task] = []

    override func fetchRemoteTasks(completion: @escaping ([Task]) -> Void) {
        if shouldReturnError {
            completion([])
        } else {
            completion(mockTasks)
        }
    }
}
