//
//  EpisodesListView.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import SwiftData
import SwiftUI

struct EpisodesListView: View {
    @StateObject private var viewModel: EpisodesViewModel

    @Query(sort: [SortDescriptor(\EpisodeEntity.id)]) private var episodes: [EpisodeEntity]

    @Query(filter: #Predicate<EpisodeFeedState> { $0.key == "episodesFeedState" })
    private var feedStateRows: [EpisodeFeedState]

    private var feedState: EpisodeFeedState? { feedStateRows.first }
    private var reachedEnd: Bool { !episodes.isEmpty && (feedState?.nextURLString == nil) }

    private let onEpisodeSelected: (Int) -> Void

    init(service: EpisodesSynchronizationService, onEpisodeSelected: @escaping (Int) -> Void) {
        _viewModel = StateObject(wrappedValue: EpisodesViewModel(service: service))
        self.onEpisodeSelected = onEpisodeSelected
    }

    var body: some View {
        List {
            lastTimeRefreshed

            ForEach(episodes) { episode in
                episodeRow(episode)
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded() }
                    }
            }

            isAtEndView
        }
        .refreshable {
            Task { await viewModel.refreshFromStart() }
        }
        .task { await viewModel.loadFirst() }
    }

    @ViewBuilder
    private var lastTimeRefreshed: some View {
        if let text = feedState?.lastRefreshed {
            Section {
                HStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text(text.formatted())
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func episodeRow(_ episode: EpisodeEntity) -> some View {
        Text(episode.name)
    }

    @ViewBuilder
    private var isAtEndView: some View {
        if reachedEnd {
            HStack {
                Spacer()
                Text("You reached the end. \(episodes.count)")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        } else if viewModel.isLoading {
            ProgressView("Loading...")
        }
    }
}

#Preview {
//    EpisodesListView(di: AppContainer())
}
