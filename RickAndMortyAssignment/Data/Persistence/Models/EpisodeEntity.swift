//
//  EpisodeEntity.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation
import SwiftData

@Model
final class EpisodeEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var airDate: Date?
    var episodeCode: String
    var characterIDs: [Int]
    var updatedAt: Date

    init(id: Int, name: String, airDate: Date?, episodeCode: String, characterIDs: [Int]) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episodeCode = episodeCode
        self.characterIDs = characterIDs
        self.updatedAt = Date()
    }
}
