//
//  Fixtures.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation
@testable import RickAndMortyAssignment

func makeEpisodeDTO(
    id: Int,
    name: String = "Pilot \(UUID().uuidString.prefix(4))",
    airDate: String = "December 2, 2013",
    code: String = "S01E01",
    characters: [Int] = [1, 2, 3]
) -> EpisodeDTO {
    EpisodeDTO(
        id: id,
        name: name,
        airDate: airDate,
        episode: code,
        characters: characters.map { URL(string: "https://rickandmortyapi.com/api/character/\($0)")! }
    )
}

func makePageDTO(
    page: Int,
    totalPages: Int,
    ids: [Int]
) -> EpisodesPageDTO {
    let next = page < totalPages
        ? "https://rickandmortyapi.com/api/episode?page=\(page + 1)"
        : nil
    return EpisodesPageDTO(
        info: PageInfoDTO(count: ids.count, pages: totalPages, next: next, prev: nil),
        results: ids.map { makeEpisodeDTO(id: $0) }
    )
}
