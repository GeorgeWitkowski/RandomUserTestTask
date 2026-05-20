//
//  UserListView.swift
//  RandomUserTestTask
//
//  Created by George on 20/05/2026.
//

import SwiftUI

struct UsersListView: View {
    @State private var viewModel = UsersViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.users.isEmpty {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error).foregroundColor(.red).padding()
                        Button("Repeat") { Task { await viewModel.fetchInitialUsers() } }
                            .buttonStyle(.bordered)
                    }
                } else {
                    List {
                        ForEach(viewModel.users) { user in
                            UserRowView(user: user)
                        }
                        
                        if !viewModel.users.isEmpty {
                            HStack {
                                Spacer()
                                
                                if viewModel.isFetchingMore {
                                    ProgressView("Loading...")
                                } else {
                                    Button(action: {
                                        Task {
                                            await viewModel.fetchNextPageIfNeeded()
                                        }
                                    }) {
                                        Text("Load more")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                            .padding(.vertical, 8)
                                    }
                                }
                                
                                Spacer()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                if viewModel.users.isEmpty {
                    await viewModel.fetchInitialUsers()
                }
            }
        }
    }
}
