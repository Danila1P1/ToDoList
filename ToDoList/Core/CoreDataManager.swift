//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import CoreData

class CoreDataManager {

    // MARK: - Singleton

    static let shared = CoreDataManager()
    init() {}

    // MARK: - CoreData Stack

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка инициализации CoreData: \(error)")
            }
        }
        return container
    }()

     var context: NSManagedObjectContext {
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
        var newTask = task
        

        if newTask.id == 0 {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            
            if let request = try? context.fetch(request), let lastEntity = request.first {
                newTask.id = lastEntity.id + 1
            } else {
                newTask.id = 1
            }
        }

        entity.configure(with: newTask)
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

    func searchTasks(matching text: String) -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        let predicate = NSPredicate(
            format: "title CONTAINS[cd] %@ OR descriptionText CONTAINS[cd] %@",
            text, text
        )
        request.predicate = predicate

        do {
            let result = try context.fetch(request)
            return result.map { Task(entity: $0) }
        } catch {
            print("Ошибка поиска в CoreData: \(error)")
            return []
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
