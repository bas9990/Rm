//
//  LocationsViewModel.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import SwiftUI

@MainActor
final class LocationsViewModel: ObservableObject {
    @Published private(set) var locations: [Location] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: LocationsRepository
    private var nextCursor: Cursor?

    init(repository: LocationsRepository) {
        self.repository = repository
    }

    func loadFirst() async {
        await load(using: .page(1), replace: true)
    }

    func loadMoreIfNeeded() async {
        guard let cursor = nextCursor else { return }
        await load(using: cursor, replace: false)
    }

    func refreshFromStart() async {
        await load(using: .page(1), replace: true)
    }

    private func load(using cursor: Cursor, replace: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await repository.load(cursor)
            locations = replace ? page.items : (locations + page.items)
            nextCursor = page.next
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Failed to load locations."
        }
    }

    var hasReachedEnd: Bool {
        !locations.isEmpty && nextCursor == nil
    }
}
