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

    @Query(filter: #Predicate<EpisodeFeedState> { $0.key == "episodes" })
    private var feedStateRows: [EpisodeFeedState]

    private var feedState: EpisodeFeedState? { feedStateRows.first }
    private var reachedEnd: Bool { !episodes.isEmpty && (feedState?.nextURLString == nil) }

    init(dependencyContainer: AppContainer) {
        let service = EpisodesSynchronizationService(
            api: dependencyContainer.apiClient,
            contextContainer: dependencyContainer.modelContainer
        )
        _viewModel = StateObject(wrappedValue: EpisodesViewModel(service: service))
    }

    var body: some View {
        List {
            ForEach(episodes) { episode in
                episodeRow(episode)
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded() }
                    }
            }

            isAtEndView
        }
        .task { await viewModel.loadFirst() }
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
