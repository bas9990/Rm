//
//  ExportFolderProviding.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

/// Abstracts where we save the export so tests can redirect to a temporary folder.
protocol ExportFolderProviding {
    func exportFolderURL() throws -> URL
}

struct DocumentsExportFolderProvider: ExportFolderProviding {
    func exportFolderURL() throws -> URL {
        let fileManager = FileManager.default
        let documents = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documents.appendingPathComponent("Exports", isDirectory: true)
    }
}
