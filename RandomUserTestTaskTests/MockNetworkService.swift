//
//  MockNetworkService.swift
//  RandomUserTestTask
//
//  Created by George on 21/05/2026.
//


import Foundation
@testable import RandomUserTestTask

final class MockNetworkService: NetworkServiceProtocol {
    var mockResult: Result<[User], Error> = .success([])
    
    var fetchCallCount = 0
    
    func fetchUsers(page: Int, resultsPerPage: Int) async throws -> [User] {
        fetchCallCount += 1
        
        switch mockResult {
        case .success(let users):
            return users
        case .failure(let error):
            throw error
        }
    }
}