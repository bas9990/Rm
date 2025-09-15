//
//  DashboardView.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct DashboardView: View {
    let onTapEpisodes: () -> Void
    let onTapCharacters: () -> Void
    let onTapLocations: () -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                DashboardCard(title: "Episodes", icon: "film", colors: [.rmYellow, .rmNavy]) {
                    onTapEpisodes()
                }
                DashboardCard(title: "Characters", icon: "person.3", colors: [.rmPink, .rmOrange]) {
                    onTapCharacters()
                }
                DashboardCard(title: "Locations", icon: "map", colors: [.rmMint, .rmBlue]) {
                    onTapLocations()
                }
            }
            .padding(16)
        }
        .navigationTitle("Rick & Morty")
        .background(Color(.systemGroupedBackground))
    }
}
