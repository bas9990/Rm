//
//  CharacterExporterTests.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

@testable import RickAndMortyAssignment
import XCTest

final class CharacterExporterTests: XCTestCase {
    // A temporary folder provider so tests do not touch real Documents.
    struct TemporaryFolderProvider: ExportFolderProviding {
        let baseURL: URL
        func exportFolderURL() throws -> URL { baseURL }
    }

    private var temporaryFolderURL: URL!
    private var exporter: CharacterExporter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        temporaryFolderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CharacterExporterTests-\(UUID().uuidString)", isDirectory: true)
        exporter = CharacterExporter(folderProvider: TemporaryFolderProvider(baseURL: temporaryFolderURL))
    }

    override func tearDownWithError() throws {
        if let url = temporaryFolderURL { try? FileManager.default.removeItem(at: url) }
        exporter = nil
        temporaryFolderURL = nil
        try super.tearDownWithError()
    }

    func testExportCreatesFolderAndWritesFile() async throws {
        let character = CharacterEntity(
            id: 1,
            name: "Morty Smith",
            status: "Alive",
            species: "Human",
            originName: "Earth",
            imageURLString: "https://example.com/morty.png",
            episodeCount: 51
        )

        let url = try await exporter.export(character)

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(url.deletingLastPathComponent(), temporaryFolderURL)

        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(CharacterExportRecord.self, from: data)
        XCTAssertEqual(decoded, CharacterExportRecord(
            name: "Morty Smith",
            status: "Alive",
            species: "Human",
            origin: "Earth",
            episodeCount: 51
        ))
    }

    func testSafeFilename() throws {
        // Use the internal writer with a dangerous name to test the filename transformation.
        let localExporter = CharacterExporter(folderProvider: TemporaryFolderProvider(baseURL: temporaryFolderURL))
        let record = CharacterExportRecord(name: "X", status: "Y", species: "Z", origin: "O", episodeCount: 1)

        // This hits the same sanitization as the async path.
        let url = try localExporter.write(record: record, filenameBase: "Bird/Person: Prime*__7")
        XCTAssertEqual(url.lastPathComponent, "Bird_Person_ Prime_7.json")
    }
}
