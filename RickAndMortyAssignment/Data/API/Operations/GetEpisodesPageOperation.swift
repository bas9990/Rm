//
//  GetEpisodesPageOperation.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation

struct GetEpisodesPageOperation: APIOperation {
    let cursor: Cursor

    var method: HTTPMethod { .GET }
    var path: String { "episode" }
    var query: [URLQueryItem] {
        if case let .page(page) = cursor { return [URLQueryItem(name: "page", value: String(page))] }
        return []
    }

    var headers: [String: String] { [:] }
    var body: Any? { nil }
    var acceptableStatus: Range<Int> { 200 ..< 300 }
    var absoluteURL: URL? {
        if case let .url(url) = cursor { return url }
        return nil
    }
}
