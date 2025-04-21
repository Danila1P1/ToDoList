//
//  TaskEntity+CoreDataProperties.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var descriptionText: String?
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?

}
