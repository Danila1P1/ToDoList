//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import CoreData

protocol ICoreDataManager: AnyObject {
    func fetchAllTasks(completion: @escaping ([Task]) -> Void)
    func create(_ task: Task, completion: @escaping () -> Void)
    func delete(_ task: Task, completion: @escaping () -> Void)
    func update(_ task: Task, completion: @escaping () -> Void)
    func searchTasks(matching text: String, on queue: DispatchQueue, completion: @escaping ([Task]) -> Void)
}

final class CoreDataManager: ICoreDataManager {

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

    func fetchAllTasks(completion: @escaping ([Task]) -> Void) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        do {
            let entities = try self.context.fetch(request)
            let tasks = entities.map { Task(entity: $0) }

            completion(tasks)
        } catch {
            print("Ошибка при загрузке задач: \(error)")
            completion([])
        }
    }

    func create(_ task: Task, completion: @escaping () -> Void) {
        let entity = TaskEntity(context: self.context)
        var newTask = task

        if newTask.id == 0 {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]

            if let request = try? self.context.fetch(request), let lastEntity = request.first {
                newTask.id = lastEntity.id + 1
            } else {
                newTask.id = 1
            }
        }

        entity.configure(with: newTask)
        self.saveContext()

        completion()
    }

    func delete(_ task: Task, completion: @escaping () -> Void) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", task.id)

        if let result = try? self.context.fetch(request), let entity = result.first {
            self.context.delete(entity)
            self.saveContext()
        }
        completion()
    }

    func update(_ task: Task, completion: @escaping () -> Void) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", task.id)

        if let result = try? self.context.fetch(request), let entity = result.first {
            entity.configure(with: task)
            self.saveContext()
        }

        completion()
    }

    func searchTasks(matching text: String, on queue: DispatchQueue, completion: @escaping ([Task]) -> Void) {
        queue.async {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

            let predicate = NSPredicate(
                format: "title CONTAINS[cd] %@ OR descriptionText CONTAINS[cd] %@",
                text, text
            )
            request.predicate = predicate

            do {
                let result = try self.context.fetch(request)
                let tasks = result.map { Task(entity: $0) }
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                print("Ошибка поиска в CoreData: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
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
