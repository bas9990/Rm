//
//  CharacterExporting.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

protocol CharacterExporting {
    func export(_ character: CharacterEntity) async throws -> URL
}
