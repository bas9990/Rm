//
//  EpisodesSynchronizationService.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation
import SwiftData

protocol EpisodesSynchronizationServiceProtocol {
    func loadInitialContent() async
    func reloadFromStart() async throws
    func loadNextPage() async throws
}

@MainActor
final class EpisodesSynchronizationService: EpisodesSynchronizationServiceProtocol {
    private let apiClient: APIClient
    private let dateParser = AirDateParser()
    private let context: ModelContext

    private var isSyncing = false

    init(api: APIClient, contextContainer: ModelContainer) {
        self.apiClient = api
        self.context = ModelContext(contextContainer)
    }

    // first load
    func loadInitialContent() async {
        let hasAny = ((try? context.fetchCount(FetchDescriptor<EpisodeEntity>())) ?? 0) > 0
        guard !hasAny else { return }
        try? await reloadFromStart()
    }

    func reloadFromStart() async throws {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        try clearAllEpisodes()

        let state = ensureState()
        state.nextURLString = nil
        state.lastRefreshed = nil
        try context.save()
        try await fetchAndUpsertNextPage(cursor: .page(1))
    }

    /// Fetch the next page (or page 1 if there is no stored cursor).
    func loadNextPage() async throws {
        guard let storedNextURL = ensureState().nextURL, !isSyncing else { return }
        isSyncing = true

        defer { isSyncing = false }

        let cursor: Cursor = .url(storedNextURL)

        try await fetchAndUpsertNextPage(cursor: cursor)
    }

    // MARK: - Internals

    private func fetchAndUpsertNextPage(cursor: Cursor) async throws {
        let dto: EpisodesPageDTO = try await apiClient.invoke(GetEpisodesPageOperation(cursor: cursor))

        let episodes = dto.results.map { $0.toDomain(using: dateParser) }

        try persist(episodes)

        let state = ensureState()
        state.nextURLString = cursor.nextURL(from: dto.info.next)?.absoluteString
        state.lastRefreshed = .now

        try context.save()
    }

    // MARK: - Persistence helpers

    private func ensureState() -> EpisodeFeedState {
        if let episodeFeedState = (try? context.fetch(FetchDescriptor<EpisodeFeedState>()))?.first {
            return episodeFeedState
        }

        let episodeFeedState = EpisodeFeedState()
        context.insert(episodeFeedState)
        try? context.save()
        return episodeFeedState
    }

    private func clearAllEpisodes() throws {
        let all = try context.fetch(FetchDescriptor<EpisodeEntity>())
        for row in all {
            context.delete(row)
        }
    }

    /// Upsert a batch; caller saves afterwards.
    private func persist(_ episodes: [Episode]) throws {
        guard !episodes.isEmpty else { return }

        let existing = try context.fetch(FetchDescriptor<EpisodeEntity>())
        var byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for episode in episodes {
            let entity = byID[episode.id] ?? {
                let episodeEntity = EpisodeEntity(
                    id: episode.id,
                    name: episode.name,
                    airDate: episode.airDate,
                    episodeCode: episode.episodeCode,
                    characterIDs: episode.characterIDs
                )
                context.insert(episodeEntity)
                byID[episode.id] = episodeEntity
                return episodeEntity
            }()

            entity.name = episode.name
            entity.airDate = episode.airDate
            entity.episodeCode = episode.episodeCode
            entity.characterIDs = episode.characterIDs
            entity.updatedAt = .now
        }
    }
}
