//
//  MockAPIClient.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation
@testable import RickAndMortyAssignment

final class MockAPIClient: APIClient {
    typealias AnyHandler = (APIOperation) throws -> Any

    private var handlersByType: [String: AnyHandler] = [:]

    private var defaultHandler: AnyHandler?

    private(set) var recordedOperations: [APIOperation] = []

    // MARK: - Configure

    func onInvoke(_ handler: @escaping AnyHandler) {
        defaultHandler = handler
    }

    func on<Operation: APIOperation>(
        _ operationType: Operation.Type,
        perform: @escaping (Operation) throws -> Any
    ) {
        let key = String(reflecting: Operation.self)
        handlersByType[key] = { operation in
            guard let concrete = operation as? Operation else { throw TestError.wrongType }
            return try perform(concrete)
        }
    }

    func stubSuccess(
        _ operationType: (some APIOperation).Type,
        returning value: some Decodable
    ) {
        on(operationType) { _ in value }
    }

    func stubFailure(
        _ operationType: (some APIOperation).Type,
        error: Error
    ) {
        on(operationType) { _ in throw error }
    }

    func reset() {
        handlersByType.removeAll()
        defaultHandler = nil
        recordedOperations.removeAll()
    }

    // MARK: - APIClient

    func invoke<Response: Decodable>(_ operation: APIOperation) async throws -> Response {
        recordedOperations.append(operation)

        let key = String(reflecting: type(of: operation))
        let handler = handlersByType[key] ?? defaultHandler
        guard let handler else { throw TestError.stubNotFound }

        let any = try handler(operation)
        guard let cast = any as? Response else { throw TestError.wrongType }
        return cast
    }
}
