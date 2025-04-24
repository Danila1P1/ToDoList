//
//  Icons.swift
//  ToDoList
//
//  Created by Danila Petrov on 21.04.2025.
//

import UIKit

public enum Icons {
    public static let circle_24 = getImage(name: "circle_24")
    public static let checkCircle_24 = getImage(name: "check_circle_24")

    public static let addTask = getImage(name: "add_task")
}

// MARK: - Private Methods

private extension Icons {

    static func getImage(name: String) -> UIImage {
        return UIImage(named: name)!
    }
}

