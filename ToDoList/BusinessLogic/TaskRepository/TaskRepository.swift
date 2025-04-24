//
//  TaskRepository.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import Foundation

protocol ITaskRepository: AnyObject {
    func loadTasks(completion: @escaping ([Task]) -> Void)
    func searchTasks(text: String, completion: @escaping ([Task]) -> Void)
}

final class TaskRepository: ITaskRepository {
    
    // MARK: - Constructors

    init(coreDataManager: ICoreDataManager, networkService: INetworkService, dispatchQueueWrapper: IDispatchQueueWrapper) {
        self.coreDataManager = coreDataManager
        self.networkService = networkService
        self.dispatchQueueWrapper = dispatchQueueWrapper
    }

    // MARK: - Public Methods

    func loadTasks(completion: @escaping ([Task]) -> Void) {
        coreDataManager.fetchAllTasks { [weak self] coreTasks in
            if coreTasks.isEmpty  && self!.isFirstLaunch() {
                self?.networkService.fetchRemoteTasks { result in
                    do {
                        let tasks = try result.get()
                        let group = DispatchGroup()

                        tasks.forEach { task in
                            group.enter()
                            self?.coreDataManager.create(task) {
                                group.leave()
                            }
                        }

                        group.notify(queue: .main) {
                            self?.setFirstLaunchDone()
                            completion(tasks)
                        }
                    } catch {
                        print("Failed to fetch remote tasks: \(error)")
                        completion([])
                    }
                }
            } else {
                completion(coreTasks)
            }
        }
    }

    func searchTasks(text: String, completion: @escaping ([Task]) -> Void) {
        coreDataManager.searchTasks(matching: text, on: dispatchQueueWrapper.asyncQueue) { tasks in
            completion(tasks)
        }
    }

    // MARK: - Private Properties

    private let coreDataManager: ICoreDataManager
    private let networkService: INetworkService
    private let dispatchQueueWrapper: IDispatchQueueWrapper
    private let isFirstLaunchKey = "isFirstLaunch"
}

// MARK: - Private Methods

private extension TaskRepository {

    func isFirstLaunch() -> Bool {
        !UserDefaults.standard.bool(forKey: isFirstLaunchKey)
    }

    func setFirstLaunchDone() {
        UserDefaults.standard.set(true, forKey: isFirstLaunchKey)
    }
}
