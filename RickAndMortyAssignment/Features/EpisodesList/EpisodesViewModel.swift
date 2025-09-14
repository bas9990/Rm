//
//  EpisodesViewModel.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import SwiftData
import SwiftUI

class EpisodesViewModel: ObservableObject {
    private let service: EpisodesSynchronizationService

    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    init(service: EpisodesSynchronizationService) {
        self.service = service
    }

    @MainActor
    func loadFirst() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        await service.loadInitialContent()
    }

    @MainActor
    func loadMoreIfNeeded() async {
        do {
            try await service.loadNextPage()
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load more."
        }
    }

    @MainActor
    func refreshFromStart() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await service.reloadFromStart()
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to refresh."
        }
    }

    func hasReachedEnd(in context: ModelContext) -> Bool {
        let state = try? context.fetch(FetchDescriptor<EpisodeFeedState>()).first
        return state?.nextURLString == nil
    }

    func lastRefreshed(in context: ModelContext) -> String? {
        guard let date = (try? context.fetch(FetchDescriptor<EpisodeFeedState>()))?.first?.lastRefreshed else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}
