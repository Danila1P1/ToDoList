//
//  DispatchQueueWrapper.swift
//  ToDoList
//
//  Created by Danila Petrov on 24.04.2025.
//

import Foundation

protocol IDispatchQueueWrapper: AnyObject {
    var asyncQueue: DispatchQueue { get }
    func sync(_ block: () -> Void)
    func async(_ block: @escaping () -> Void)
}

final class DispatchQueueWrapper: IDispatchQueueWrapper {
    
    // MARK: - Constructors

    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }

    // MARK: - Public Properties

    var asyncQueue: DispatchQueue {
        return dispatchQueue
    }

    // MARK: - Public Properties

    func sync(_ block: () -> Void) {
        dispatchQueue.sync(execute: block)
    }

    func async(_ block: @escaping () -> Void) {
        dispatchQueue.async(execute: block)
    }

    // MARK: - Private Properties

    private let dispatchQueue: DispatchQueue
}
