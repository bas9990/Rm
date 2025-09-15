//
//  GetCharactersByIDsOperation.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation

struct GetCharactersByIDsOperation: APIOperation {
    var absoluteURL: URL?

    let method: HTTPMethod = .GET
    var path: String { "character/\(csv)" }
    private let csv: String
    init(ids: [Int]) {
        precondition(ids.count >= 2, "Use GetCharacterOperation for a single id.")
        self.csv = ids.map(String.init).joined(separator: ",")
    }
}
