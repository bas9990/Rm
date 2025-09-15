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
    private let charactersService: CharactersSynchronizationService

    init(
        episodesService: EpisodesSynchronizationService,
        charactersService: CharactersSynchronizationService
    ) {
        self.episodesService = episodesService
        self.charactersService = charactersService
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
            EpisodeDetailsView(episodeID: episodeID, charactersSync: charactersService) { [weak self] id in
                self?.push(.characterDetail(id: id))
            }

        case let .characterDetail(id):
            CharacterDetailsView(characterID: id)
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
