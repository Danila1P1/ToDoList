//
//  Task.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import Foundation

struct Task: Identifiable {

    var id: Int64
    var title: String
    var descriptionText: String
    var isCompleted: Bool
    var createdAt: Date
}
