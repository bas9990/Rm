//
//  EpisodesSynchronizationServiceTests.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

@testable import RickAndMortyAssignment
import SwiftData
import XCTest

final class EpisodesSynchronizationServiceTests: XCTestCase {
    func testInitialLoadSeedsPage1WhenStoreEmpty() async throws {
        let container = try makeInMemoryContainer()
        let mock = MockAPIClient()
        // Return page 1 with next=page2
        mock.onInvoke { operation in
            guard let get = operation as? GetEpisodesPageOperation else { throw TestError.wrongType }
            switch get.cursor {
            case .page(1): return makePageDTO(page: 1, totalPages: 3, ids: [1, 2, 3])
            default: throw TestError.forced
            }
        }
        let service = await EpisodesSynchronizationService(api: mock, contextContainer: container)

        await service.loadInitialContent()

        let ctx = ModelContext(container)
        let rows = try fetchAllEpisodes(ctx)
        XCTAssertEqual(rows.map(\.id), [1, 2, 3])

        let state = try XCTUnwrap(fetchFeedState(ctx))
        XCTAssertEqual(state.nextURLString, "https://rickandmortyapi.com/api/episode?page=2")
        XCTAssertNotNil(state.lastRefreshed)
    }

    func testInitialLoadDoesNothingWhenStoreHasEpisodes() async throws {
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)
        // Seed one episode
        ctx.insert(EpisodeEntity(id: 42, name: "Seed", airDate: nil, episodeCode: "S00E00", characterIDs: []))
        try ctx.save()

        let mock = MockAPIClient()
        // If invoked, we blow up (should not be called)
        mock.onInvoke { _ in throw TestError.forced }

        let service = await EpisodesSynchronizationService(api: mock, contextContainer: container)
        await service.loadInitialContent()

        let rows = try fetchAllEpisodes(ctx)
        XCTAssertEqual(rows.map(\.id), [42]) // Unchanged, no network call
    }

    func testLoadNextPagePersistsAndAdvancesCursor() async throws {
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)

        // Seed state with next=page2
        let state = EpisodeFeedState()
        state.nextURLString = "https://rickandmortyapi.com/api/episode?page=2"
        ctx.insert(state)
        try ctx.save()

        let mock = MockAPIClient()
        mock.onInvoke { operation in
            guard let get = operation as? GetEpisodesPageOperation else { throw TestError.wrongType }
            switch get.cursor {
            case let .url(url):
                XCTAssertTrue(url.absoluteString.hasSuffix("page=2"))
                return makePageDTO(page: 2, totalPages: 2, ids: [4, 5]) // end here, next=nil
            default:
                throw TestError.forced
            }
        }

        let service = await EpisodesSynchronizationService(api: mock, contextContainer: container)
        try await service.loadNextPage()

        let rows = try fetchAllEpisodes(ctx)
        XCTAssertEqual(rows.map(\.id), [4, 5])

        let updated = try XCTUnwrap(fetchFeedState(ctx))
        XCTAssertNil(updated.nextURLString) // end reached
        XCTAssertNotNil(updated.lastRefreshed)
    }

    func testReloadFromStartClearsAndFetchesPage1() async throws {
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)

        // Seed some other episodes
        ctx.insert(EpisodeEntity(id: 99, name: "Old", airDate: nil, episodeCode: "OLD", characterIDs: []))
        try ctx.save()

        let mock = MockAPIClient()
        mock.onInvoke { operation in
            guard let get = operation as? GetEpisodesPageOperation else { throw TestError.wrongType }
            switch get.cursor {
            case .page(1): return makePageDTO(page: 1, totalPages: 1, ids: [7, 8, 9])
            default: throw TestError.forced
            }
        }

        let service = await EpisodesSynchronizationService(api: mock, contextContainer: container)
        try await service.reloadFromStart()

        let rows = try fetchAllEpisodes(ctx)
        XCTAssertEqual(rows.map(\.id), [7, 8, 9])

        let state = try XCTUnwrap(fetchFeedState(ctx))
        XCTAssertNil(state.nextURLString) // only 1 page in this stub
    }

    func testLoadNextPageNoOpWhenAtEnd() async throws {
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)

        // Seed state with next=nil (end)
        let state = EpisodeFeedState()
        state.nextURLString = nil
        ctx.insert(state)
        try ctx.save()

        let mock = MockAPIClient()
        // If invoked, fail (should not be called)
        mock.onInvoke { _ in throw TestError.forced }

        let service = await EpisodesSynchronizationService(api: mock, contextContainer: container)
        try await service.loadNextPage() // should no-op, no throw

        let rows = try fetchAllEpisodes(ctx)
        XCTAssertTrue(rows.isEmpty)
    }
}
