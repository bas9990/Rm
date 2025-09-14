//
//  TestError.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

@testable import RickAndMortyAssignment
import SwiftData
import XCTest

enum TestError: Error { case stubNotFound, wrongType, forced }

func makeInMemoryContainer() throws -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: EpisodeEntity.self, EpisodeFeedState.self, configurations: config)
}

func fetchAllEpisodes(_ context: ModelContext) throws -> [EpisodeEntity] {
    try context.fetch(FetchDescriptor<EpisodeEntity>(sortBy: [SortDescriptor(\.id)]))
}

func fetchFeedState(_ context: ModelContext) throws -> EpisodeFeedState? {
    try context.fetch(FetchDescriptor<EpisodeFeedState>()).first
}
