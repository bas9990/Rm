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
    let episodeSyncService: EpisodesSynchronizationServiceProtocol

    init(modelContainer: ModelContainer, apiClient: APIClient = RMAPIClient()) {
        self.modelContainer = modelContainer
        self.apiClient = apiClient
        self.episodeSyncService = EpisodesSynchronizationService(api: apiClient, contextContainer: modelContainer)
    }
}
