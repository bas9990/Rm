//
//  EpisodeDetailsView.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftData
import SwiftUI

struct EpisodeDetailsView: View {
    let episodeID: Int
    let charactersSync: CharactersSynchronizationServiceProtocol
    var onSelectCharacter: ((Int) -> Void)?

    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel: EpisodeDetailsViewModel

    // Load the episode once by ID
    @Query private var episodes: [EpisodeEntity]
    private var episode: EpisodeEntity? { episodes.first }

    // Load all characters; we filter locally to those referenced by the episode
    @Query(sort: [SortDescriptor(\CharacterEntity.name, order: .forward)])
    private var allCharacters: [CharacterEntity]

    private var characterIDs: [Int] { episode?.characterIDs ?? [] }
    private var charactersForEpisode: [CharacterEntity] {
        let set = Set(characterIDs)
        return allCharacters.filter { set.contains($0.id) }.sorted { $0.id < $1.id }
    }

    private var grid: [GridItem] { [GridItem(.adaptive(minimum: 150), spacing: 12)] }

    init(
        episodeID: Int,
        charactersSync: CharactersSynchronizationServiceProtocol,
        onSelectCharacter: ((Int) -> Void)? = nil
    ) {
        self.episodeID = episodeID
        self.charactersSync = charactersSync
        self.onSelectCharacter = onSelectCharacter

        _episodes = Query(
            filter: #Predicate<EpisodeEntity> { $0.id == episodeID },
            sort: [SortDescriptor(\EpisodeEntity.id)]
        )
        _viewModel = StateObject(wrappedValue: EpisodeDetailsViewModel(charactersSync: charactersSync))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let episode {
                    EpisodeHeaderCard(episode: episode.asDomain)
                } else {
                    // Simple placeholder while episode loads from SwiftData
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.15))
                        .frame(height: 110)
                        .padding(.horizontal, 16)
                        .redacted(reason: .placeholder)
                }

                // Characters
                VStack(alignment: .leading, spacing: 8) {
                    if !(episode?.characterIDs.isEmpty ?? true) {
                        Text("Characters")
                            .font(.headline)
                            .padding(.horizontal, 16)

                        if charactersForEpisode.isEmpty, viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Loading characters…")
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        } else if charactersForEpisode.isEmpty {
                            // No data yet (e.g. offline first run) — still show a friendly state
                            Text("Characters are loading…")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                        } else {
                            LazyVGrid(columns: grid, spacing: 12) {
                                ForEach(charactersForEpisode, id: \.id) { character in
                                    CharacterTile(character: character) {
                                        onSelectCharacter?(character.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    } else {
                        Text("No characters in this episode.")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Episode")
        .task(id: characterIDs) {
            await viewModel.fetchRequiredCharacters(for: characterIDs)
        }
    }
}
