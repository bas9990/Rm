//
//  MockAPIClient.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation
@testable import RickAndMortyAssignment

final class MockAPIClient: APIClient {
    private typealias AnyHandler = (APIOperation) throws -> Any
    private var handlersByOperationKey: [String: AnyHandler] = [:]

    func reset() { handlersByOperationKey.removeAll() }

    // MARK: - Stubbing

    /// Always return a fixed success value for the given operation type.
    func stubSuccess<OperationType: APIOperation>(
        for operationType: OperationType.Type,
        returning value: some Decodable
    ) {
        handlersByOperationKey[key(forOperationType: OperationType.self)] = { _ in value }
    }

    /// Always throw the given error for the given operation type.
    func stubFailure<OperationType: APIOperation>(
        for operationType: OperationType.Type,
        throwing error: Error
    ) {
        handlersByOperationKey[key(forOperationType: OperationType.self)] = { _ in throw error }
    }

    /// Decide the result dynamically based on the concrete operation’s properties.
    func on<OperationType: APIOperation>(
        _ operationType: OperationType.Type,
        perform: @escaping (OperationType) throws -> some Decodable
    ) {
        handlersByOperationKey[key(forOperationType: OperationType.self)] = { operation in
            guard let typedOperation = operation as? OperationType else {
                fatalError("Stub type mismatch. Expected \(OperationType.self), got \(type(of: operation))")
            }
            return try perform(typedOperation)
        }
    }

    // MARK: - APIClient

    func invoke<Response: Decodable>(_ operation: APIOperation) async throws -> Response {
        let operationKey = key(forOperation: operation)
        guard let handler = handlersByOperationKey[operationKey] else {
            fatalError("No stub for \(operationKey). Add a stub before calling invoke.")
        }

        let anyResult = try handler(operation)

        guard let typedResult = anyResult as? Response else {
            fatalError("Stub returned \(type(of: anyResult)) but call expects \(Response.self) for \(operationKey).")
        }

        return typedResult
    }

    // MARK: - Keys

    private func key(forOperation operation: APIOperation) -> String {
        String(reflecting: type(of: operation))
    }

    private func key<OperationType: APIOperation>(forOperationType _: OperationType.Type) -> String {
        String(reflecting: OperationType.self)
    }
}
