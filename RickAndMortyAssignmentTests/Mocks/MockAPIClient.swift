//
//  MockAPIClient.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation
@testable import RickAndMortyAssignment

final class MockAPIClient: APIClient {
    typealias Handler = (APIOperation) throws -> Any
    private var handler: Handler?

    func onInvoke(_ handler: @escaping Handler) {
        self.handler = handler
    }

    func invoke<Response: Decodable>(_ operation: APIOperation) async throws -> Response {
        guard let handler else { throw TestError.stubNotFound }
        let any = try handler(operation)
        guard let cast = any as? Response else { throw TestError.wrongType }
        return cast
    }
}
