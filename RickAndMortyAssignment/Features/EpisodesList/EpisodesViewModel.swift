//
//  EpisodesViewModel.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import SwiftUI

class EpisodesViewModel: ObservableObject {
    @Published private(set) var episodes: [Episode] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var isAtEnd: Bool {
        !episodes.isEmpty && nextCursor == nil
    }

    private let repository: EpisodesRepository
    private var nextCursor: Cursor?

    init(repository: EpisodesRepository) {
        self.repository = repository
    }

    func loadFirst() async {
        await load(using: .page(1), replace: true)
    }

    func loadNextIfNeeded(currentItem: Episode) async {
        guard episodes.last?.id == currentItem.id, let cursor = nextCursor else { return }
        await load(using: cursor, replace: false)
    }

    @MainActor
    private func load(using cursor: Cursor, replace: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await repository.load(cursor)
            episodes = replace ? page.episodes : (episodes + page.episodes)
            nextCursor = page.next
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong."
        }
    }
}
