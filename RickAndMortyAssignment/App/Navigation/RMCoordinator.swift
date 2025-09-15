//
//  RMCoordinator.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

@MainActor
final class RMCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    private let episodesService: EpisodesSynchronizationService

    init(episodesService: EpisodesSynchronizationService) {
        self.episodesService = episodesService
    }

    func push(_ page: RMPage) { path.append(page) }
    func pop() { guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() { path = NavigationPath() }

    @ViewBuilder
    func build(page: RMPage) -> some View {
        switch page {
        case .dashboard:
            DashboardView(
                onTapEpisodes: { [weak self] in self?.push(.episodesList) },
                onTapCharacters: { [weak self] in print("TODO") },
                onTapLocations: { [weak self] in print("TODO") }
            )

        case .episodesList:
            EpisodesListView(service: episodesService) { [weak self] id in
                self?.push(.episodeCharacters(episodeID: id))
            }

            //        case .charactersList:
            //            PlaceholderScreen(title: "Characters list (coming soon)")
            //        case .locationsList:
            //            PlaceholderScreen(title: "Locations list (coming soon)")

        case let .episodeCharacters(episodeID):
            PlaceholderScreen(title: "episodeID \(episodeID) detail (coming soon)")

        case let .characterDetail(id):
            PlaceholderScreen(title: "Character \(id) detail (coming soon)")
            //
            //        case .locationDetail(let id):
            //            PlaceholderScreen(title: "Location \(id) detail (coming soon)")
            //        }
        }
    }
}

// During development TODO: remove when go live
private struct PlaceholderScreen: View {
    let title: String
    var body: some View {
        Text(title).foregroundStyle(.secondary).navigationTitle(title)
    }
}
