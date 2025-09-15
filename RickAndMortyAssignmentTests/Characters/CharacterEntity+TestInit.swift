//
//  CharacterEntity+TestInit.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

@testable import RickAndMortyAssignment

// Test-only helper so we can construct a fully-populated CharacterEntity
extension CharacterEntity {
    convenience init(
        id: Int,
        name: String,
        status: String,
        species: String,
        originName: String,
        imageURLString: String? = nil,
        episodeCount: Int
    ) {
        self.init(id: id) // use the app’s designated init
        self.name = name
        self.status = status
        self.species = species
        self.originName = originName
        self.imageURLString = imageURLString
        self.episodeCount = episodeCount
    }
}
