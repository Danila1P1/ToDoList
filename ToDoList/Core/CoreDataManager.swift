//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import CoreData

final class CoreDataManager {

    // MARK: - Singleton

    static let shared = CoreDataManager()
    private init() {}

    // MARK: - CoreData Stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка инициализации CoreData: \(error)")
            }
        }
        return container
    }()

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Public Methods

    func fetchAllTasks() -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        do {
            let entities = try context.fetch(request)
            return entities.map { Task(entity: $0) }
        } catch {
            print("Ошибка при загрузке задач: \(error)")
            return []
        }
    }

    func create(_ task: Task) {
        let entity = TaskEntity(context: context)
        entity.configure(with: task)
        saveContext()
    }

    func delete(_ task: Task) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", task.id)

        if let result = try? context.fetch(request), let entity = result.first {
            context.delete(entity)
            saveContext()
        }
    }

    func update(_ task: Task) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", task.id)

        if let result = try? context.fetch(request), let entity = result.first {
            entity.configure(with: task)
            saveContext()
        }
    }
}

// MARK: - Private Methods

private extension CoreDataManager {

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка при сохранении контекста: \(error)")
            }
        }
    }
}
