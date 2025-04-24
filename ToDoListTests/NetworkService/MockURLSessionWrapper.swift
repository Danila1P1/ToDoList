//
//  MockURLSessionWrapper.swift
//  ToDoListTests
//
//  Created by Danila Petrov on 25.04.2025.
//

import Foundation
@testable import ToDoList

final class MockURLSessionWrapper: IURLSessionWrapper {

    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {

        return MockURLSessionDataTask {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
    }
}

final class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }
    override func resume() {
        closure()
    }
}
