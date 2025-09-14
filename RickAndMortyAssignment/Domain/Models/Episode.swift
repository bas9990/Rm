//
//  Episode.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation

struct Episode: Identifiable, Equatable, Hashable {
    let id: Int
    var name: String
    var airDate: Date?
    var episodeCode: String
    var characterIDs: [Int]
}

extension Episode {
    var formattedAirDate: String {
        guard let airDate else { return "—" }
        return Episode.dateFormatter.string(from: airDate)
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()
}
