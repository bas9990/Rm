//
//  EpisodesViewModelTests.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

@testable import RickAndMortyAssignment
import SwiftData
import XCTest

final class EpisodesViewModelTests: XCTestCase {
    func testRefreshFromStartSetsErrorOnFailure() async throws {
        let container = try makeInMemoryContainer()

        // Mock fails on page 1 call
        let mock = MockAPIClient()
        mock.onInvoke { _ in throw TestError.forced }

        let service = await EpisodesSynchronizationService(api: mock, contextContainer: container, appEnviorment: .mock)
        let viewmodel = EpisodesViewModel(service: service)

        await viewmodel.refreshFromStart()

        XCTAssertNotNil(viewmodel.errorMessage)
        XCTAssertFalse(viewmodel.isLoading)
    }

    func testLoadFirstSeedsWhenEmpty() async throws {
        let container = try makeInMemoryContainer()
        let mock = MockAPIClient()
        mock.onInvoke { operation in
            guard let get = operation as? GetEpisodesPageOperation else { throw TestError.wrongType }
            switch get.cursor {
            case .page(1): return makePageDTO(page: 1, totalPages: 2, ids: [1, 2])
            default: throw TestError.forced
            }
        }
        let service = await EpisodesSynchronizationService(api: mock, contextContainer: container, appEnviorment: .mock)
        let viewModel = EpisodesViewModel(service: service)

        await viewModel.loadFirst()
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)

        // Verify persisted
        let ctx = ModelContext(container)
        let rows = try fetchAllEpisodes(ctx)
        XCTAssertEqual(rows.map(\.id), [1, 2])
    }
}
