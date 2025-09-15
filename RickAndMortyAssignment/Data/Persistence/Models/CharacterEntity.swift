//
//  CharacterEntity.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation
import SwiftData

@Model
final class CharacterEntity: Identifiable {
    @Attribute(.unique) var id: Int
    var name = ""
    var status = ""
    var species = ""
    var originName = ""
    var imageURLString: String?
    var episodeCount = 0
    var updatedAt = Date()

    init(id: Int) { self.id = id }
    var imageURL: URL? { imageURLString.flatMap(URL.init(string:)) }
}
