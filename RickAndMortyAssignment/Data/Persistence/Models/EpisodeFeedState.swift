//
//  EpisodeFeedState.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 14/09/2025.
//

import Foundation
import SwiftData

@Model
final class EpisodeFeedState {
    @Attribute(.unique) var key: String = "episodesFeedState"
    var nextURLString: String?
    var lastRefreshed: Date?

    var nextURL: URL? { nextURLString.flatMap(URL.init(string:)) }

    init(nextURLString: String? = nil, lastRefreshed: Date? = nil) {
        self.nextURLString = nextURLString
        self.lastRefreshed = lastRefreshed
    }
}
