//
//  EpisodeDetailsViewModel.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation

@MainActor
final class EpisodeDetailsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let charactersSync: CharactersSynchronizationServiceProtocol

    init(charactersSync: CharactersSynchronizationServiceProtocol) {
        self.charactersSync = charactersSync
    }

    func fetchRequiredCharacters(for characterIDs: [Int]) async {
        guard !characterIDs.isEmpty, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        await charactersSync.fetchRequiredCharacters(for: characterIDs)

        errorMessage = nil
    }
}
