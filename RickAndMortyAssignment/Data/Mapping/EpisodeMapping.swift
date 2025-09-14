//
//  EpisodeMapping.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation

struct AirDateParser {
    private let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()

    func parse(_ raw: String) -> Date? { formatter.date(from: raw) }
}

extension EpisodeDTO {
    func toDomain(using parser: AirDateParser) -> Episode {
        Episode(
            id: id,
            name: name,
            airDate: parser.parse(airDate),
            episodeCode: episode,
            characterIDs: characters.compactMap { Int($0.lastPathComponent) }
        )
    }
}
