//
//  EpisodesRepository.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation

protocol EpisodesRepository {
    func load(_ cursor: Cursor) async throws -> EpisodesPage
    func loadFirstPage() async throws -> EpisodesPage
}

final class RemoteEpisodesRepository: EpisodesRepository {
    private let apiClient: APIClient
    private let dateParser = AirDateParser()

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func loadFirstPage() async throws -> EpisodesPage {
        try await load(.page(1))
    }

    func load(_ cursor: Cursor) async throws -> EpisodesPage {
        let dto: EpisodesPageDTO = try await apiClient.invoke(
            GetEpisodesPageOperation(cursor: cursor)
        )
        let items = dto.results.map { $0.toDomain(using: dateParser) }
        let next = cursor.nextURL(from: dto.info.next).map(Cursor.url)
        return EpisodesPage(episodes: items, next: next)
    }
}
