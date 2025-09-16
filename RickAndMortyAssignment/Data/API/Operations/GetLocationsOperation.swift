//
//  GetLocationsOperation.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

struct GetLocationsPageOperation: APIOperation {
    let method: HTTPMethod = .GET
    let path: String = "/location"

    let cursor: Cursor

    var absoluteURL: URL? {
        if case let .url(url) = cursor { return url }
        return nil
    }

    var query: [URLQueryItem] {
        if case let .page(pageId) = cursor { return [URLQueryItem(name: "page", value: String(pageId))] }
        return []
    }
}
