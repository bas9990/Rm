//
//  APIError.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 13/09/2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(URLError)
    case serverError(status: Int, data: Data?)
    case invalidResponse
    case decodingFailed(Error)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL."
        case let .requestFailed(error): "Network request failed: \(error.localizedDescription)"
        case let .serverError(error, _): "Server error (\(error))."
        case .invalidResponse: "Invalid response."
        case let .decodingFailed(error): "Decoding failed: \(error.localizedDescription)"
        case .cancelled: "Request cancelled."
        }
    }
}
