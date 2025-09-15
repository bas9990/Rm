//
//  EpisodeMapping.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation

struct AirDateParser {
    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter
    }()

    func parse(_ raw: String) -> Date? {
        let string = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let date = Self.formatter.date(from: string) { return date }

        return nil
    }
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
