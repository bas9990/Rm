//
//  EpisodeEntityMapping.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation
import SwiftData

extension EpisodeEntity {
    var asDomain: Episode {
        Episode(
            id: id,
            name: name,
            airDate: airDate,
            episodeCode: episodeCode,
            characterIDs: characterIDs
        )
    }
}
