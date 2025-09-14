//
//  Cursor.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation

enum Cursor: Equatable, Hashable {
    case page(Int)
    case url(URL)
}

extension Cursor {
    var absoluteURL: URL? {
        if case let .url(absoluteURL) = self { return absoluteURL }
        return nil
    }

    func nextURL(from nextString: String?) -> URL? {
        guard let nextString, let url = URL(string: nextString) else { return nil }
        return url
    }
}
