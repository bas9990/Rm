//
//  ModelContainerProvider.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import SwiftData

enum ModelContainerProvider {
    static func make() throws -> ModelContainer {
        let schema = Schema([EpisodeEntity.self, EpisodeFeedState.self])
        let config = ModelConfiguration("RickAndMortyAssignment")
        return try ModelContainer(for: schema, configurations: config)
    }
}
