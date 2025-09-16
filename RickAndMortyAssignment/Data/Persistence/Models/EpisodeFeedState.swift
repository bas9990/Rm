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

    /// Anchor: the last page we fetched for the list (truth from request).
    var currentPageURLString: String?

    /// Background refresh pointer; we refresh this page next, then we fetch prev,
    /// this way we make sure we refresh the currently loaded pages .
    var refreshPointerURLString: String?

    var nextURL: URL? { nextURLString.flatMap(URL.init(string:)) }

    var lastUsedPageWithNumber: Int?

    init(
        nextURLString: String? = nil,
        lastRefreshed: Date? = nil,
        refreshPointerURLString: String? = nil,
        lastUsedPageWithNumber: Int? = nil
    ) {
        self.nextURLString = nextURLString
        self.lastRefreshed = lastRefreshed
        self.refreshPointerURLString = refreshPointerURLString
        self.lastUsedPageWithNumber = lastUsedPageWithNumber
    }
}
