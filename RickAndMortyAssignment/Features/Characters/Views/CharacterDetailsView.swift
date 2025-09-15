//
//  CharacterDetailsView.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftData
import SwiftUI

struct CharacterDetailsView: View {
    let characterID: Int

    @Query private var rows: [CharacterEntity]
    private var character: CharacterEntity? { rows.first }

    @State private var exportedFileURL: URL?
    @State private var isLoading: Bool = false
    private let characterExporter = CharacterExporter()

    init(characterID: Int) {
        self.characterID = characterID
        _rows = Query(
            filter: #Predicate<CharacterEntity> { $0.id == characterID },
            sort: [SortDescriptor(\CharacterEntity.id)]
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let character {
                    CharacterDetailsViewHeader(
                        imageURL: character.imageURLString.flatMap(URL.init(string:)),
                        name: character.name,
                        status: character.status
                    )

                    InfoCard(
                        species: character.species,
                        origin: character.originName,
                        episodesCount: character.episodeCount,
                        updatedAt: character.updatedAt
                    )
                    .padding(.horizontal, 16)
                } else {
                    // Placeholder while SwiftData populates
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.gray.opacity(0.15))
                        .frame(height: 220)
                        .padding(.horizontal, 16)
                        .redacted(reason: .placeholder)
                }
            }
            .padding(.vertical, 16)
        }
        .toolbar {
            if isLoading {
                ProgressView()
            } else {
                if let character {
                    Button(
                        action: {
                            Task {
                                do {
                                    isLoading = true
                                    exportedFileURL = try await characterExporter.export(character)
                                    isLoading = false
                                } catch {
                                    isLoading = false
                                    print("Export failed:", error)
                                }
                            }
                        },
                        label: { Image(systemName: "square.and.arrow.up") }
                    )
                    .accessibilityLabel("Export character")
                }
            }
        }
        .sheet(item: $exportedFileURL) { url in
            ShareSheetView(items: [url])
        }
        .navigationTitle("Character")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension URL: Identifiable { public var id: String { absoluteString } }
