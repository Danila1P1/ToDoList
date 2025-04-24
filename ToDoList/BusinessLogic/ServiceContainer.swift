//
//  ServiceContainer.swift
//  ToDoList
//
//  Created by Danila Petrov on 24.04.2025.
//

import Foundation

protocol Deps: TaskListVCDeps {}

final class ServiceContainer: Deps {
    static let shared: Deps = ServiceContainer()

    lazy var coreDataManager: ICoreDataManager = CoreDataManager()
    lazy var dispatchQueueWrapper: IDispatchQueueWrapper = DispatchQueueWrapper(dispatchQueue: DispatchQueue.main)
    lazy var taskRepository: ITaskRepository = TaskRepository(coreDataManager: coreDataManager, networkService: networkService, dispatchQueueWrapper: dispatchQueueWrapper)

    private let networkService: INetworkService = NetworkService(dispatchQueue: DispatchQueueWrapper(dispatchQueue: DispatchQueue.global(qos: .background)), urlSessionWrapper: URLSessionWrapper(urlSession: URLSession.shared))
}
