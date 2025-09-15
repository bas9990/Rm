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
                Button(
                    action: { onEpisodeSelected(episode.id) },
                    label: { episodeRow(episode) }
                )
            }

            footer
        }
        .toolbar {
            // Users might not see the loading cell
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
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
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.rmNavy)
                HStack {
                    Badge(
                        text: episode.episodeCode,
                        systemImage: "film",
                        foreground: .white,
                        background: .rmNavy.opacity(0.6)
                    )
                    Badge(
                        text: episode.asDomain.formattedAirDate,
                        systemImage: "calendar",
                        foreground: .white,
                        background: .rmOrange.opacity(0.6)
                    )
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var footer: some View {
        if reachedEnd {
            HStack {
                Spacer()
                Text("You reached the end. \(episodes.count)")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        } else if !episodes.isEmpty {
            LoadMoreTrigger(isLoading: viewModel.isLoading) {
                await viewModel.loadMoreIfNeeded()
            }
        }
    }
}

#Preview {
//    EpisodesListView(di: AppContainer())
}
