//
//  Item.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 12/09/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
