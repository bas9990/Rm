//
//  EpisodeDetailsViewModelTests.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

@testable import RickAndMortyAssignment
import XCTest

@MainActor
final class EpisodeDetailsViewModelTests: XCTestCase {
    func test_fetchRequiredCharacters_callsServiceAndTogglesLoading() async {
        let charactersSyn = MockCharactersSync()
        let viewModel = EpisodeDetailsViewModel(charactersSync: charactersSyn)

        await viewModel.fetchRequiredCharacters(for: [1, 2, 3])

        XCTAssertEqual(charactersSyn.calls, [[1, 2, 3]])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_fetchRequiredCharacters_ignoresEmptyIDs() async {
        let svc = MockCharactersSync()
        let viewModel = EpisodeDetailsViewModel(charactersSync: svc)

        await viewModel.fetchRequiredCharacters(for: [])
        XCTAssertTrue(svc.calls.isEmpty)
    }
}

@MainActor
final class MockCharactersSync: CharactersSynchronizationServiceProtocol {
    private(set) var calls: [[Int]] = []
    func fetchRequiredCharacters(for characterIDs: [Int]) async { calls.append(characterIDs) }
}
