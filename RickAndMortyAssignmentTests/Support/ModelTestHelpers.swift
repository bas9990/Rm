//
//  ModelTestHelpers.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

@testable import RickAndMortyAssignment
import SwiftData
import XCTest

enum TestError: Error { case stubNotFound, wrongType, forced }

func makeInMemoryContainer() throws -> ModelContainer {
    try ModelContainer(for: Schema([
        EpisodeEntity.self,
        EpisodeFeedState.self,
        CharacterEntity.self,
    ]), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
}

func fetchAllEpisodes(_ context: ModelContext) throws -> [EpisodeEntity] {
    try context.fetch(FetchDescriptor<EpisodeEntity>(sortBy: [SortDescriptor(\.id)]))
}

func fetchFeedState(_ context: ModelContext) throws -> EpisodeFeedState? {
    try context.fetch(FetchDescriptor<EpisodeFeedState>()).first
}

func fetchAllCharacters(_ context: ModelContext) throws -> [CharacterEntity] {
    try context.fetch(FetchDescriptor<CharacterEntity>(sortBy: [SortDescriptor(\.id)]))
}

// Handy DTO factory
func makeCharacterDTO(id: Int) -> CharacterDTO {
    CharacterDTO(
        id: id,
        name: "Name \(id)",
        status: "Alive",
        species: "Human",
        image: "https://example.com/\(id).png",
        origin: .init(name: "Earth", url: nil),
        episode: ["https://rickandmortyapi.com/api/episode/1"]
    )
}

// Parse ids from bulk op path: "character/1,2,3"
func idsFromBulkPath(_ path: String) -> [Int] {
    path.replacingOccurrences(of: "character/", with: "")
        .split(separator: ",")
        .compactMap { Int($0) }
}
