//
//  URLSessionWrapper.swift
//  ToDoList
//
//  Created by Danila Petrov on 24.04.2025.
//

import Foundation

protocol IURLSessionWrapper: AnyObject {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

final class URLSessionWrapper: IURLSessionWrapper {
    
    // MARK: - Constructors

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    // MARK: - Public Methods

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return urlSession.dataTask(with: request, completionHandler: completionHandler)
    }

    // MARK: - Private Properties

    private let urlSession: URLSession
}
