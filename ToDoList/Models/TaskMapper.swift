//
//  TaskMapper.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import Foundation

extension Task {

    init(entity: TaskEntity) {
        self.id = entity.id
        self.title = entity.title ?? ""
        self.descriptionText = entity.descriptionText ?? ""
        self.isCompleted = entity.isCompleted
        self.createdAt = entity.createdAt ?? Date()
    }
}

extension TaskEntity {

    func configure(with task: Task) {
        self.id = task.id
        self.title = task.title
        self.descriptionText = task.descriptionText
        self.isCompleted = task.isCompleted
        self.createdAt = task.createdAt
    }
}
