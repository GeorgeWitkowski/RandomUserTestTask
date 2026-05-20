//
//  NetworkError.swift
//  RandomUserTestTask
//
//  Created by George on 20/05/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "Invalid response from the server."
        case .serverError(let code):
            return "Server returned an error with status code \(code)."
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}
