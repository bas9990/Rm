//
//  GetCharacterOperation.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation

struct GetCharacterOperation: APIOperation {
    var absoluteURL: URL?

    let method: HTTPMethod = .GET
    var path: String { "character/\(id)" }
    let id: Int
}
