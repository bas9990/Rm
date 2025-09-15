//
//  CharacterExportRecord.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

struct CharacterExportRecord: Codable, Equatable {
    let name: String
    let status: String
    let species: String
    let origin: String
    let episodeCount: Int
}
