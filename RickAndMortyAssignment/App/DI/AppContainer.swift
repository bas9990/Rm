//
//  AppContainer.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import SwiftData
import SwiftUI

@MainActor
final class AppContainer: ObservableObject {
    let modelContainer: ModelContainer
    let apiClient: APIClient
    let coordinator: RMCoordinator
    let episodeSyncService: EpisodesSynchronizationService
    let charactersSync: CharactersSynchronizationService

    init(modelContainer: ModelContainer, apiClient: APIClient = RMAPIClient()) {
        self.modelContainer = modelContainer
        self.apiClient = apiClient
        self.episodeSyncService = EpisodesSynchronizationService(api: apiClient, contextContainer: modelContainer)
        self.charactersSync = CharactersSynchronizationService(apiClient: apiClient, contextContainer: modelContainer)
        self.coordinator = .init(
            episodesService: .init(
                api: apiClient,
                contextContainer: modelContainer
            ),
            charactersService: charactersSync
        )
    }
}
