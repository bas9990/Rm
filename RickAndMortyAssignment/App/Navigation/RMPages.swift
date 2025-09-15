//
//  RMPages.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//
import Foundation

enum RMPage: Hashable {
    case dashboard
    case episodesList
    case episodeCharacters(episodeID: Int)
    case characterDetail(id: Int) // placeholder for next step
}
