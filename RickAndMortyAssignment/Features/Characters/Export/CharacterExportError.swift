//
//  CharacterExportError.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

enum CharacterExportError: LocalizedError {
    case couldNotCreateFolder
    case couldNotWriteFile

    var errorDescription: String? {
        switch self {
        case .couldNotCreateFolder: "Could not create the export folder."
        case .couldNotWriteFile: "Could not write the export file."
        }
    }
}
