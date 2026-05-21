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
}
