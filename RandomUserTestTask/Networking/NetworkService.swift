//
//  NetworkService.swift
//  RandomUserTestTask
//
//  Created by George on 20/05/2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchUsers(page: Int, resultsPerPage: Int) async throws -> [User]
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://randomuser.me/api/"
    
    private let seed = "ios"
    
    func fetchUsers(page: Int, resultsPerPage: Int) async throws -> [User] {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "results", value: String(resultsPerPage)),
            URLQueryItem(name: "seed", value: seed)
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let responseData = try decoder.decode(RandomUserResponse.self, from: data)
            return responseData.results
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}


