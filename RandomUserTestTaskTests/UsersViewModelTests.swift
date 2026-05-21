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
}
