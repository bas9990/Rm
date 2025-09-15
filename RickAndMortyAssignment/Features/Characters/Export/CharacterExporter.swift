//
//  CharacterExporter.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation

struct CharacterExporter: CharacterExporting {
    private let folderProvider: ExportFolderProviding
    private let fileManager: FileManager
    private let encoder: JSONEncoder

    init(
        folderProvider: ExportFolderProviding = DocumentsExportFolderProvider(),
        fileManager: FileManager = .default,
        encoder: JSONEncoder = .prettyForExport()
    ) {
        self.folderProvider = folderProvider
        self.fileManager = fileManager
        self.encoder = encoder
    }

    func export(_ character: CharacterEntity) async throws -> URL {
        // Snapshot SwiftData model on the main actor
        let snapshot = await MainActor.run {
            (
                id: character.id,
                name: character.name,
                record: CharacterExportRecord(
                    name: character.name,
                    status: character.status,
                    species: character.species,
                    origin: character.originName,
                    episodeCount: character.episodeCount
                )
            )
        }

        // Perform blocking file work on a background thread
        return try await Task.detached(priority: .utility) {
            try write(record: snapshot.record, filenameBase: "\(snapshot.name)_\(snapshot.id)")
        }.value
    }

    // MARK: - Internals

    func write(record: CharacterExportRecord, filenameBase: String) throws -> URL {
        let data = try encoder.encode(record)

        let folder = try folderProvider.exportFolderURL()
        if !fileManager.fileExists(atPath: folder.path) {
            do {
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            } catch {
                throw CharacterExportError.couldNotCreateFolder
            }
        }

        let safeName = makeSafeFilename(filenameBase) + ".json"
        let destination = folder.appendingPathComponent(safeName)

        do {
            try data.write(to: destination, options: .atomic)
        } catch {
            throw CharacterExportError.couldNotWriteFile
        }

        return destination
    }

    private func makeSafeFilename(_ raw: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ ."))
        let mapped = String(raw.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" })

        let collapsed = mapped.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
        return collapsed
    }
}
