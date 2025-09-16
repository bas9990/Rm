//
//  Location.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

struct Location: Identifiable, Equatable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residentIDs: [Int]
    let residentCount: Int
}

extension LocationDTO {
    func toDomain() -> Location {
        let ids = residents.compactMap { URL(string: $0)?.lastPathComponent }.compactMap(Int.init)
        return Location(
            id: id,
            name: name,
            type: type,
            dimension: dimension,
            residentIDs: ids,
            residentCount: ids.count
        )
    }
}
