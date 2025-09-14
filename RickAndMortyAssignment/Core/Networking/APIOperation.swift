//
//  APIOperation.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 13/09/2025.
//

import Foundation

protocol APIOperation {
    var method: HTTPMethod { get }
    var path: String { get }
    var query: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Any? { get }
    var acceptableStatus: Range<Int> { get }

    /// If set, the client uses this URL directly..
    var absoluteURL: URL? { get }
}

extension APIOperation {
    var query: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Any? { nil }
    var acceptableStatus: Range<Int> { 200 ..< 300 }

    func encodeBody() throws -> Data? {
        try body.map { try JSONSerialization.data(withJSONObject: $0, options: []) }
    }
}
