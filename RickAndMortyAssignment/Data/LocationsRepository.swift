//
//  LocationsRepository.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

protocol LocationsRepository {
    func load(_ cursor: Cursor) async throws -> (items: [Location], next: Cursor?)
    func loadFirstPage() async throws -> (items: [Location], next: Cursor?)
}

final class RemoteLocationsRepository: LocationsRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func loadFirstPage() async throws -> (items: [Location], next: Cursor?) {
        try await load(.page(1))
    }

    func load(_ cursor: Cursor) async throws -> (items: [Location], next: Cursor?) {
        let dto: LocationsPageDTO = try await apiClient.invoke(
            GetLocationsPageOperation(cursor: cursor)
        )
        let items = dto.results.map { $0.toDomain() }
        let next = cursor.nextURL(from: dto.info.next).map(Cursor.url)
        return (items, next)
    }
}
