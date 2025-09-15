//
//  CharactersSynchronizationServiceTests.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

@testable import RickAndMortyAssignment
import SwiftData
import XCTest

@MainActor
final class CharactersSynchronizationServiceTests: XCTestCase {
    func test_insertsMissingAndSkipsExisting_usesBulkForMissing() async throws {
        // GIVEN: store with id 1 already cached
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)
        ctx.insert(CharacterEntity(id: 1))
        try ctx.save()

        // AND: mock API that returns DTOs, recording bulk ids
        let api = MockAPIClient()
        var bulkCalls: [[Int]] = []

        api.on(GetCharacterOperation.self) { operation in
            // Should NOT be used in this scenario
            makeCharacterDTO(id: operation.id)
        }
        api.on(GetCharactersByIDsOperation.self) { operation in
            let ids = idsFromBulkPath(operation.path)
            bulkCalls.append(ids)
            return ids.map { makeCharacterDTO(id: $0) }
        }

        let service = CharactersSynchronizationService(apiClient: api, contextContainer: container)

        // WHEN
        await service.fetchRequiredCharacters(for: [1, 2, 3])

        // THEN: DB has 1,2,3 and network only fetched [2,3] once (bulk)
        let all = try fetchAllCharacters(ctx)
        XCTAssertEqual(all.map(\.id), [1, 2, 3])
        XCTAssertEqual(bulkCalls.count, 1)
        XCTAssertEqual(Set(bulkCalls[0]), Set([2, 3]))
    }

    func test_batchesOverMaxBatchSize() async throws {
        // GIVEN: 25 ids → service.maxBatchSize = 20 ⇒ expect [20, 5]
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)
        let ids = Array(1 ... 25)

        let api = MockAPIClient()
        var batchSizes: [Int] = []

        api.on(GetCharactersByIDsOperation.self) { operation in
            let ids = idsFromBulkPath(operation.path)
            batchSizes.append(ids.count)
            return ids.map { makeCharacterDTO(id: $0) }
        }
        api.on(GetCharacterOperation.self) { operation in
            // not expected here (all chunks > 1)
            makeCharacterDTO(id: operation.id)
        }

        let service = CharactersSynchronizationService(apiClient: api, contextContainer: container)

        // WHEN
        await service.fetchRequiredCharacters(for: ids)

        // THEN
        XCTAssertEqual(try fetchAllCharacters(ctx).map(\.id), ids)
        XCTAssertEqual(batchSizes, [20, 5])
    }

    func test_noNetworkWhenAllCached() async throws {
        // GIVEN: all cached
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)
        [1, 2, 3].forEach { ctx.insert(CharacterEntity(id: $0)) }
        try ctx.save()

        let api = MockAPIClient()
        var bulkCalls = 0
        var singleCalls = 0

        api.on(GetCharactersByIDsOperation.self) { operation in
            bulkCalls += 1
            return idsFromBulkPath(operation.path).map { makeCharacterDTO(id: $0) }
        }
        api.on(GetCharacterOperation.self) { operation in
            singleCalls += 1
            return makeCharacterDTO(id: operation.id)
        }

        let service = CharactersSynchronizationService(apiClient: api, contextContainer: container)

        // WHEN
        await service.fetchRequiredCharacters(for: [1, 2, 3])

        // THEN: no network calls
        XCTAssertEqual(bulkCalls, 0)
        XCTAssertEqual(singleCalls, 0)
        XCTAssertEqual(try fetchAllCharacters(ctx).map(\.id), [1, 2, 3])
    }

    func test_bestEffortContinuesOnBatchFailure() async throws {
        // GIVEN: two batches (20 + 20), second fails
        let container = try makeInMemoryContainer()
        let ctx = ModelContext(container)
        let ids = Array(1 ... 40)

        let api = MockAPIClient()
        api.on(GetCharactersByIDsOperation.self) { operation in
            let ids = idsFromBulkPath(operation.path)
            if ids.contains(21) { throw TestError.forced } // fail 2nd chunk
            return ids.map { makeCharacterDTO(id: $0) }
        }

        let service = CharactersSynchronizationService(apiClient: api, contextContainer: container)

        // WHEN
        await service.fetchRequiredCharacters(for: ids)

        // THEN: only first batch persisted
        XCTAssertEqual(try fetchAllCharacters(ctx).map(\.id), Array(1 ... 20))
    }
}
