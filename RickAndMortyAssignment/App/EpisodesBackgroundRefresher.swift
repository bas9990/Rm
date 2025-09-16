//
//  EpisodesBackgroundRefresher.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import Foundation

@MainActor
final class EpisodesBackgroundRefresher {
    private let episodesService: EpisodesSynchronizationService

    init(episodesService: EpisodesSynchronizationService) {
        self.episodesService = episodesService
    }

    func performRefresh() async {
        print("Refreshing episodes background...")
        await episodesService.refreshLoadedPagesBackward()
    }
}
