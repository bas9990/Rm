//
//  EpisodesListView.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import SwiftUI

struct EpisodesListView: View {
    @StateObject private var viewModel: EpisodesViewModel

    init(episodesRepository: EpisodesRepository) {
        self._viewModel = StateObject(wrappedValue: .init(repository: episodesRepository))
    }

    var body: some View {
        List {
            ForEach(viewModel.episodes) { episode in
                episodeRow(episode)
                    .onAppear {
                        Task { await viewModel.loadNextIfNeeded(currentItem: episode) }
                    }
            }

            isAtEndView
        }
        .task { await viewModel.loadFirst() }
    }

    @ViewBuilder
    private func episodeRow(_ episode: Episode) -> some View {
        Text(episode.name)
    }

    @ViewBuilder
    private var isAtEndView: some View {
        if viewModel.isAtEnd {
            HStack {
                Spacer()
                Text("You reached the end. \(viewModel.episodes.count)")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        } else if viewModel.isLoading {
            ProgressView("Loading...")
        }
    }
}

#Preview {
    EpisodesListView(episodesRepository: RemoteEpisodesRepository(apiClient: RMAPIClient()))
}
