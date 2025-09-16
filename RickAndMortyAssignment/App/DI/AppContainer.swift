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
    let environment: AppEnvironment
    let apiClient: APIClient
    let locationRepository: LocationsRepository
    let coordinator: RMCoordinator
    let episodeSyncService: EpisodesSynchronizationService
    let charactersSync: CharactersSynchronizationService

    init(
        modelContainer: ModelContainer,
        apiClient: APIClient = RMAPIClient(),
        environment: AppEnvironment = .production
    ) {
        self.modelContainer = modelContainer
        self.environment = environment
        self.apiClient = apiClient
        self.episodeSyncService = EpisodesSynchronizationService(
            api: apiClient,
            contextContainer: modelContainer,
            appEnviorment: environment
        )
        self.locationRepository = RemoteLocationsRepository(apiClient: apiClient)
        self.charactersSync = CharactersSynchronizationService(apiClient: apiClient, contextContainer: modelContainer)
        self.coordinator = .init(
            episodesService: episodeSyncService,
            charactersService: charactersSync,
            locationRepository: locationRepository
        )
    }
}
