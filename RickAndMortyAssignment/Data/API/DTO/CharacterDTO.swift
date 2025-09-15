//
//  CharacterDTO.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation

struct OriginRef: Decodable {
    let name: String
    let url: String?
}

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String
    let origin: OriginRef
    let episode: [String]
}
