//
//  MockLocationsRepository.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

@testable import RickAndMortyAssignment
import XCTest

final class MockLocationsRepository: LocationsRepository {
    struct Stub {
        let result: Result<([Location], Cursor?), Error>
    }

    private var stubs: [Cursor: Stub] = [:]
    private(set) var callCount = 0

    // Optional artificial delay to test isLoading guard / overlap
    var artificialDelay: TimeInterval = 0

    func stub(_ cursor: Cursor, items: [Location], next: Cursor?) {
        stubs[cursor] = Stub(result: .success((items, next)))
    }

    func stubError(_ cursor: Cursor, error: Error) {
        stubs[cursor] = Stub(result: .failure(error))
    }

    func load(_ cursor: Cursor) async throws -> (items: [Location], next: Cursor?) {
        callCount += 1

        if artificialDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(artificialDelay * 1_000_000_000))
        }

        guard let stub = stubs[cursor] else {
            XCTFail("No stub for cursor: \(cursor)")
            throw TestError.stubNotFound
        }
        switch stub.result {
        case let .success(payload):
            return payload
        case let .failure(error):
            throw error
        }
    }

    // Not used by the view model, but part of the protocol in some setups.
    func loadFirstPage() async throws -> (items: [Location], next: Cursor?) {
        try await load(.page(1))
    }
}
