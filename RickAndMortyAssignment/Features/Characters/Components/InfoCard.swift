//
//  InfoCard.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct InfoCard: View {
    let species: String
    let origin: String
    let episodesCount: Int
    let updatedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Badge(
                    text: species.isEmpty ? "—" : species,
                    systemImage: "person.fill",
                    foreground: .white,
                    background: .rmBlue
                )
                Badge(
                    text: origin.isEmpty ? "—" : origin,
                    systemImage: "globe",
                    foreground: .white,
                    background: .rmBlue
                )
            }

            Divider().opacity(0.2)

            HStack {
                StatTile(icon: "film.stack", title: "Episodes", value: "\(episodesCount)")
                Spacer(minLength: 14)
                StatTile(icon: "clock", title: "Updated", value: updatedText)
            }
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }

    private var updatedText: String {
        guard let date = updatedAt else { return "—" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

private struct StatTile: View {
    let icon: String
    let title: String
    let value: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).font(.title3).frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Text(value).font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
