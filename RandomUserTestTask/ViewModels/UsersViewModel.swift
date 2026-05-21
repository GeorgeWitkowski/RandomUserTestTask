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
    var users: [User] = []
    
    // MARK: - Search Properties
    var searchText: String = "" {
        didSet {
            debounceSearch()
        }
    }
    private var debouncedSearchText: String = ""
    private var searchTask: Task<Void, Never>?

    var filteredUsers: [User] {
        if debouncedSearchText.isEmpty {
            return users
        }
        
        let query = debouncedSearchText.lowercased()
        return users.filter { user in
            user.fullName.lowercased().contains(query) ||
            user.email.lowercased().contains(query)
        }
    }

    // MARK: - State Properties
    var isLoading: Bool = false
    var isFetchingMore = false
    var errorMessage: String? = nil
    
    private var currentPage: Int = 1
    private let resultsPerPage: Int = 40
    
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Persistenct Properties
    private let cacheKey = "saved_users_cache"
    private let blacklistKey = "deleted_users_blacklist"
    private var deletedUserIDs: Set<String> = []
    
    // MARK: - Initialization
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        loadBlacklist()
    }
    
    // MARK: - Search Logic (Debounce)
    private func debounceSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.debouncedSearchText = self.searchText
            }
        }
    }
    
    // MARK: - Actions
    
    @MainActor
    func fetchInitialUsers() async {
        if let cachedUsers = loadCachedUsers(), !cachedUsers.isEmpty {
            self.users = cachedUsers
            self.currentPage = (cachedUsers.count / resultsPerPage) + 1
            return
        }
        
        guard users.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        defer { isLoading = false }
        
        do {
            let newUsers = try await networkService.fetchUsers(page: currentPage, resultsPerPage: resultsPerPage)
            self.users = removeDuplicatesAndDeleted(from: newUsers)
            saveUsersToCache(self.users)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func fetchNextPageIfNeeded() async {
        guard !isFetchingMore else { return }
        
        isFetchingMore = true
        
        let nextPage = currentPage + 1
        
        defer { isFetchingMore = false }
        
        do {
            let newUsers = try await networkService.fetchUsers(page: nextPage, resultsPerPage: resultsPerPage)
            
            let uniqueNewUsers = removeDuplicatesAndDeleted(from: newUsers)
            self.users.append(contentsOf: uniqueNewUsers)
            
            self.currentPage = nextPage
            saveUsersToCache(self.users)
            
        } catch {
            print("Failed to fetch next page: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Persistence
    
    private func saveUsersToCache(_ users: [User]) {
        do {
            let data = try JSONEncoder().encode(users)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("Failed to save users: \(error)")
        }
    }
    
    private func loadCachedUsers() -> [User]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        
        do {
            return try JSONDecoder().decode([User].self, from: data)
        } catch {
            print("Failed to decode users: \(error)")
            return nil
        }
    }
    
    private func saveBlacklist() {
        do {
            let data = try JSONEncoder().encode(deletedUserIDs)
            UserDefaults.standard.set(data, forKey: blacklistKey)
        } catch {
            print("Failed to save blacklist: \(error)")
        }
    }
    
    private func loadBlacklist() {
        guard let data = UserDefaults.standard.data(forKey: blacklistKey) else { return }
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            deletedUserIDs = decoded
        }
    }
    
    // MARK: - Delete Logic

    func deleteUser(_ user: User) {
        users.removeAll { $0.id == user.id }
        
        deletedUserIDs.insert(user.id)
        saveBlacklist()

        saveUsersToCache(users)
    }
    
    // MARK: - Helper Methods
    
    private func removeDuplicatesAndDeleted(from newUsers: [User]) -> [User] {
        var uniqueUsers = [User]()
        var seenIDs = Set<String>()
        
        for user in users {
            seenIDs.insert(user.id)
        }
        
        for user in newUsers {
            if !seenIDs.contains(user.id) && !deletedUserIDs.contains(user.id) {
                seenIDs.insert(user.id)
                uniqueUsers.append(user)
            }
        }
        
        return uniqueUsers
    }
}
