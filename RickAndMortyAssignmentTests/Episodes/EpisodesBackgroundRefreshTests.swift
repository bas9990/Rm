//
//  EpisodesBackgroundRefreshTests.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

@testable import RickAndMortyAssignment
import SwiftData
import XCTest

final class EpisodesBackgroundRefreshTests: XCTestCase {
    @MainActor
    func testRefreshBackwardWalksToBeginningAndClearsPointer() async throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        // Seed a feed state that points at page 3
        let feedState = EpisodeFeedState()
        feedState.refreshPointerURLString = episodePageURL(3).absoluteString
        context.insert(feedState)
        try context.save()

        // Stub: for any page=n URL, return a page DTO with previous = n-1
        let mockClient = MockAPIClient()
        mockClient.onInvoke { operation in
            guard
                let getOperation = operation as? GetEpisodesPageOperation,
                case let .url(url) = getOperation.cursor,
                let pageNumber = pageNumber(fromEpisodePageURL: url)
            else { throw TestError.wrongType }

            let previousURLString = (pageNumber > 1) ? episodePageURL(pageNumber - 1).absoluteString : nil

            return makeEpisodePageDTO(
                page: pageNumber,
                totalPages: 3,
                previous: previousURLString,
                next: nil,
                episodeIDs: [pageNumber] // store episode with id = pageNumber
            )
        }

        let service = EpisodesSynchronizationService(api: mockClient, contextContainer: container, appEnviorment: .mock)
        await service.refreshLoadedPagesBackward()

        // Episodes for pages 3,2,1 should be persisted
        let persisted = try fetchAllEpisodes(context)
        XCTAssertEqual(persisted.map(\.id), [1, 2, 3])

        // Pointer should be cleared after reaching the beginning
        let updatedState = try fetchFeedState(context)
        XCTAssertNil(updatedState?.refreshPointerURLString)
        XCTAssertNotNil(updatedState?.lastRefreshed)
    }

    // MARK: - Error mid-walk: stop and keep pointer where it stopped

    @MainActor
    func testRefreshBackwardStopsOnErrorAndKeepsPointer() async throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let feedState = EpisodeFeedState()
        feedState.refreshPointerURLString = episodePageURL(3).absoluteString
        context.insert(feedState)
        try context.save()

        let mockClient = MockAPIClient()
        mockClient.onInvoke { operation in
            guard
                let getOperation = operation as? GetEpisodesPageOperation,
                case let .url(url) = getOperation.cursor,
                let pageNumber = pageNumber(fromEpisodePageURL: url)
            else { throw TestError.wrongType }

            // Make page 2 fail
            if pageNumber == 2 { throw TestError.forced }

            let previousURLString = (pageNumber > 1) ? episodePageURL(pageNumber - 1).absoluteString : nil

            return makeEpisodePageDTO(
                page: pageNumber,
                totalPages: 3,
                previous: previousURLString,
                next: nil,
                episodeIDs: [pageNumber]
            )
        }

        let service = EpisodesSynchronizationService(api: mockClient, contextContainer: container, appEnviorment: .mock)
        await service.refreshLoadedPagesBackward()

        // Only page 3 should be saved
        let persisted = try fetchAllEpisodes(context)
        XCTAssertEqual(persisted.map(\.id), [3])

        // Pointer should now point at the failing page=2 (kept for next run)
        let updatedState = try fetchFeedState(context)
        XCTAssertEqual(updatedState?.refreshPointerURLString, episodePageURL(2).absoluteString)
    }

    // MARK: - No pointer: do nothing

    @MainActor
    func testRefreshBackwardWithoutPointerDoesNothing() async throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        let feedState = EpisodeFeedState()
        feedState.refreshPointerURLString = nil
        context.insert(feedState)
        try context.save()

        // Any invocation would crash this stub—so the method must not call it.
        let mockClient = MockAPIClient()
        mockClient.onInvoke { _ in throw TestError.forced }

        let service = EpisodesSynchronizationService(api: mockClient, contextContainer: container, appEnviorment: .mock)
        await service.refreshLoadedPagesBackward()

        XCTAssertEqual(try fetchAllEpisodes(context).count, 0)
        let updatedState = try fetchFeedState(context)
        XCTAssertNil(updatedState?.refreshPointerURLString)
    }
}

// MARK: - Local helpers (no abbreviations)

/// Build the canonical episode-page URL the same way the app does.
private func episodePageURL(_ page: Int) -> URL {
    URL(string: "https://rickandmortyapi.com/api/episode?page=\(page)")!
}

/// Extract the `page` query parameter from an episode-page URL.
private func pageNumber(fromEpisodePageURL url: URL) -> Int? {
    URLComponents(url: url, resolvingAgainstBaseURL: false)?
        .queryItems?
        .first(where: { $0.name == "page" })?
        .value
        .flatMap(Int.init)
}

/// Construct a page DTO with the minimal fields used by the sync logic.
private func makeEpisodePageDTO(
    page: Int,
    totalPages: Int,
    previous: String?,
    next: String?,
    episodeIDs: [Int]
) -> EpisodesPageDTO {
    let results: [EpisodeDTO] = episodeIDs.map {
        EpisodeDTO(
            id: $0,
            name: "Episode \($0)",
            airDate: "December 2, 2013",
            episode: "S01E\($0)",
            characters: []
        )
    }

    let info = PageInfoDTO(
        count: totalPages,
        pages: totalPages,
        next: next,
        prev: previous
    )
    return EpisodesPageDTO(info: info, results: results)
}
