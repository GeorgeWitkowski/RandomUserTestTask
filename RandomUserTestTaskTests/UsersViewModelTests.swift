//
//  UsersViewModelTests.swift
//  RandomUserTestTask
//
//  Created by George on 21/05/2026.
//

import XCTest
@testable import RandomUserTestTask

@MainActor
final class UsersViewModelTests: XCTestCase {
    
    var viewModel: UsersViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        mockNetworkService = MockNetworkService()
        viewModel = UsersViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchInitialUsers_Success_PopulatesUsersArray() async {
        // Arrange
        let mockUser1 = User.mock(first: "John")
        let mockUser2 = User.mock(first: "Jane")
        
        mockNetworkService.mockResult = .success([mockUser1, mockUser2])
        
        XCTAssertTrue(viewModel.users.isEmpty, "Users array should initially be empty")
        
        // Act
        await viewModel.fetchInitialUsers()
        
        // Assert
        XCTAssertEqual(mockNetworkService.fetchCallCount, 1, "Network service should be called exactly once")
        XCTAssertEqual(viewModel.users.count, 2, "Users array should contain exactly 2 users")
        XCTAssertEqual(viewModel.users.first?.name.first, "John", "The first user should be John")
        XCTAssertFalse(viewModel.isLoading, "Loading state should be false after fetching")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
    }
    
    func testFetchInitialUsers_WithDuplicates_RemovesDuplicates() async {
        // Arrange
        let user1 = User.mock(first: "John", email: "john@gmail.com")
        let user2 = User.mock(first: "Jane", email: "jane@gmail.com")
        let duplicateUser = User.mock(first: "John Clone", email: "john@gmail.com")
        
        mockNetworkService.mockResult = .success([user1, user2, duplicateUser])
        
        // Act
        await viewModel.fetchInitialUsers()
        
        // Assert
        XCTAssertEqual(viewModel.users.count, 2, "Users array should contain only 2 unique users")
        XCTAssertEqual(viewModel.users[0].email, "john@gmail.com", "First user should be John")
        XCTAssertEqual(viewModel.users[1].email, "jane@gmail.com", "Second user should be Jane")
    }
    
    func testDeleteUser_AddsToBlacklistAndFiltersFromFutureFetches() async {
        // Arrange
        let userToKeep = User.mock(first: "Jane", email: "jane@gmail.com")
        let userToDelete = User.mock(first: "John", email: "john@gmail.com")
        viewModel.users = [userToKeep, userToDelete]
        
        // Act
        viewModel.deleteUser(userToDelete)
        
        // Assert
        XCTAssertEqual(viewModel.users.count, 1, "Users array should contain 1 user after deletion")
        XCTAssertEqual(viewModel.users.first?.email, "jane@gmail.com", "Remaining user should be Jane")
        
        // Arrange (Setup for next page fetch)
        let newUser = User.mock(first: "Bob", email: "bob@gmail.com")
        mockNetworkService.mockResult = .success([userToDelete, newUser])
        
        // Act
        await viewModel.fetchNextPageIfNeeded()
        
        // Assert
        XCTAssertEqual(viewModel.users.count, 2, "Array should contain Jane and Bob, but not John")
        XCTAssertFalse(viewModel.users.contains { $0.email == "john@gmail.com" }, "Deleted user should NOT be added back from network")
        XCTAssertTrue(viewModel.users.contains { $0.email == "bob@gmail.com" }, "New user Bob should be added")
    }
    
    func testSearchText_WithDebounce_FiltersUsers() async throws {
        // Arrange
        let user1 = User.mock(first: "Alice", email: "alice@gmail.com")
        let user2 = User.mock(first: "Bob", email: "bob@gmail.com")
        let user3 = User.mock(first: "Charlie", email: "charlie@gmail.com")
        
        viewModel.users = [user1, user2, user3]
        
        XCTAssertEqual(viewModel.filteredUsers.count, 3, "Initially, all users should be visible")
        
        // Act
        viewModel.searchText = "ali"
        
        // Assert
        XCTAssertEqual(viewModel.filteredUsers.count, 3, "Filter should not apply immediately due to debounce")
        
        // Act
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Assert
        XCTAssertEqual(viewModel.filteredUsers.count, 1, "Filter should apply after debounce time has passed")
        XCTAssertEqual(viewModel.filteredUsers.first?.name.first, "Alice", "Only Alice should remain in the filtered list")
    }
    
    func testFetchInitialUsers_NetworkError_SetsErrorMessage() async {
        // Arrange
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockNetworkService.mockResult = .failure(expectedError)
        
        // Act
        await viewModel.fetchInitialUsers()
        
        // Assert
        XCTAssertEqual(mockNetworkService.fetchCallCount, 1, "Network service should be called")
        XCTAssertTrue(viewModel.users.isEmpty, "Users array should remain empty on error")
        XCTAssertFalse(viewModel.isLoading, "Loading state should be false even after an error")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should not be nil")
    }
    
    func testFetchNextPageIfNeeded_Success_AppendsUsers() async {
        // Arrange
        let initialUser = User.mock(first: "Alice", email: "alice@gmail.com")
        viewModel.users = [initialUser]
        
        let newUser = User.mock(first: "Bob", email: "bob@gmail.com")
        mockNetworkService.mockResult = .success([newUser])
        
        // Act
        await viewModel.fetchNextPageIfNeeded()
        
        // Assert
        XCTAssertEqual(mockNetworkService.fetchCallCount, 1, "Network service should be called once")
        XCTAssertEqual(viewModel.users.count, 2, "New users should be appended to the existing array, not replace it")
        XCTAssertEqual(viewModel.users.first?.email, "alice@gmail.com", "First user should still be Alice")
        XCTAssertEqual(viewModel.users.last?.email, "bob@gmail.com", "Last user should be Bob")
        XCTAssertFalse(viewModel.isFetchingMore, "isFetchingMore should be reset to false")
    }
}
