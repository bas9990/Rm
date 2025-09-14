//
//  Episode.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation

struct Episode: Identifiable, Equatable, Hashable {
    let id: Int
    var name: String
    var airDate: Date?
    var episodeCode: String
    var characterIDs: [Int]
}
