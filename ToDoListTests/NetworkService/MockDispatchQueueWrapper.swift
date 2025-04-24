//
//  MockDispatchQueueWrapper.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import Foundation
@testable import ToDoList

final class MockDispatchQueueWrapper: IDispatchQueueWrapper {

    private var pendingBlocks: [() -> Void] = []

    var asyncQueue: DispatchQueue {
        return DispatchQueue.global()
    }

    func sync(_ block: () -> Void) {
        block()
    }

    func async(_ block: @escaping () -> Void) {
        pendingBlocks.append(block)
    }

    func executePending() {
        pendingBlocks.forEach { $0() }
        pendingBlocks.removeAll()
    }
}
