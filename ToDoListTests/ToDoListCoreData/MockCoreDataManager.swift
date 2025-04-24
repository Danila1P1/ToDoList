//
//  MockCoreDataManager.swift
//  ToDoList
//
//  Created by Danila Petrov on 24.04.2025.
//

import CoreData
@testable import ToDoList

final class MockCoreDataManager: CoreDataManager {

    private let inMemoryContainer: NSPersistentContainer

    override var context: NSManagedObjectContext {
        return inMemoryContainer.viewContext
    }

    override init() {
        inMemoryContainer = NSPersistentContainer(name: "ToDoList")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        inMemoryContainer.persistentStoreDescriptions = [description]

        inMemoryContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("In-memory store error: \(error)")
            }
        }
    }

    override func fetchAllTasks() -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let result = try? context.fetch(request)
        return result?.map(Task.init) ?? []
    }

    override func create(_ task: Task) {
        let entity = TaskEntity(context: context)
        entity.configure(with: task)
        saveContext()
    }

    override func delete(_ task: Task) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", task.id)
        if let result = try? context.fetch(request), let entity = result.first {
            context.delete(entity)
            saveContext()
        }
    }

    override func update(_ task: Task) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", task.id)
        if let result = try? context.fetch(request), let entity = result.first {
            entity.configure(with: task)
            saveContext()
        }
    }

    override func searchTasks(matching text: String) -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR descriptionText CONTAINS[cd] %@", text, text)
        let result = try? context.fetch(request)
        return result?.map(Task.init) ?? []
    }

    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
