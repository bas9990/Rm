//
//  AppEnvironment.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

struct AppEnvironment: Sendable, Equatable {
    var apiBaseURL: URL

    static let production = AppEnvironment(
        apiBaseURL: URL(string: "https://rickandmortyapi.com/api")!
    )
    #if DEBUG
        static let mock = AppEnvironment(
            apiBaseURL: URL(string: "https://example.invalid/api")!
        )
    #endif
}
