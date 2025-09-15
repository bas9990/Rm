//
//  CharactersSynchronizationService.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import Foundation
import SwiftData

@MainActor
protocol CharactersSynchronizationServiceProtocol: AnyObject {
    func fetchRequiredCharacters(for characterIDs: [Int]) async
}

@MainActor
final class CharactersSynchronizationService: CharactersSynchronizationServiceProtocol {
    private let apiClient: APIClient
    private let modelContext: ModelContext

    private let maxBatchSize = 20

    init(apiClient: APIClient, contextContainer: ModelContainer) {
        self.apiClient = apiClient
        self.modelContext = ModelContext(contextContainer)
    }

    func fetchRequiredCharacters(for characterIDs: [Int]) async {
        print(characterIDs)
        let ids = Array(Set(characterIDs)).sorted()
        guard !ids.isEmpty else { return }

        // Determine missing IDs
        let existing = (try? modelContext.fetch(FetchDescriptor<CharacterEntity>())) ?? []
        let existingIDs = Set(existing.map(\.id))
        let missingIDs = ids.filter { !existingIDs.contains($0) }
        guard !missingIDs.isEmpty else { return }

        // Fetch and upsert in batches
        for batch in missingIDs.chunked(into: maxBatchSize) {
            do {
                if batch.count == 1 {
                    let dto: CharacterDTO = try await apiClient.invoke(GetCharacterOperation(id: batch[0]))
                    upsertCharacter(from: dto)
                    print("JERER")
                } else {
                    let dtos: [CharacterDTO] = try await apiClient.invoke(GetCharactersByIDsOperation(ids: batch))
                    dtos.forEach { upsertCharacter(from: $0) }
                    print("JERERasd")
                }
                try? modelContext.save()
            } catch {
                // Best-effort: log and continue with the next batch.
                print("⚠️ Character fetch failed for batch \(batch): \(error)")
            }
        }
    }

    private func upsertCharacter(from dto: CharacterDTO) {
        let id = dto.id

        var fetch = FetchDescriptor<CharacterEntity>(
            predicate: #Predicate<CharacterEntity> { $0.id == id }
        )
        fetch.fetchLimit = 1

        let existing = try? modelContext.fetch(fetch).first
        let entity = existing ?? CharacterEntity(id: id)

        entity.name = dto.name
        entity.status = dto.status
        entity.species = dto.species
        entity.originName = dto.origin.name
        entity.imageURLString = dto.image
        entity.episodeCount = dto.episode.count
        entity.updatedAt = .now

        if existing == nil { modelContext.insert(entity) }
    }
}

private extension Array {
    /// Split the array into consecutive chunks, each with at most `maxSize` elements.
    func chunked(into maxSize: Int) -> [[Element]] {
        guard maxSize > 0 else { return [self] }

        var chunks: [[Element]] = []
        var start = 0

        while start < count {
            let end = Swift.min(start + maxSize, count) // end index (non-inclusive)
            chunks.append(Array(self[start ..< end]))
            start = end
        }
        return chunks
    }
}
