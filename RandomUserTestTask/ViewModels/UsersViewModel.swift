//
//  UsersViewModel.swift
//  RandomUserTestTask
//
//  Created by George on 20/05/2026.
//


import Foundation
import Observation

@Observable
final class UsersViewModel {
    // MARK: - Properties
    
    var users: [User] = []
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private var currentPage: Int = 1
    private let resultsPerPage: Int = 20
    private var isFetchingNextPage: Bool = false
    
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Initialization
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Actions
    
    @MainActor
    func fetchInitialUsers() async {
        guard users.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        do {
            let newUsers = try await networkService.fetchUsers(page: currentPage, resultsPerPage: resultsPerPage)
            self.users = removeDuplicates(from: newUsers)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchNextPageIfNeeded(currentUser: User) async {
        guard currentUser.id == users.last?.id, !isFetchingNextPage else { return }
        
        isFetchingNextPage = true
        currentPage += 1
        
        do {
            let newUsers = try await networkService.fetchUsers(page: currentPage, resultsPerPage: resultsPerPage)
            
            let uniqueNewUsers = removeDuplicates(from: newUsers)
            self.users.append(contentsOf: uniqueNewUsers)
            
        } catch {
            print("Failed to fetch next page: \(error.localizedDescription)")
        }
        
        isFetchingNextPage = false
    }
    
    // MARK: - Helper Methods
    
    private func removeDuplicates(from newUsers: [User]) -> [User] {
        var uniqueUsers = [User]()
        var seenIDs = Set<String>()
        
        for user in users {
            seenIDs.insert(user.id)
        }
        
        for user in newUsers {
            if !seenIDs.contains(user.id) {
                seenIDs.insert(user.id)
                uniqueUsers.append(user)
            }
        }
        
        return uniqueUsers
    }
}
