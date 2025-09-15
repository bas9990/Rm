//
//  EpisodeHeaderCard.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct EpisodeHeaderCard: View {
    let episode: Episode

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(episode.name)
                .font(.title2).bold()
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                Badge(text: episode.episodeCode, systemImage: "film")
                Badge(text: episode.formattedAirDate, systemImage: "calendar")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [.rmBlue, .rmNavy],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .overlay(.black.opacity(0.15))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 6, y: 3)
        .padding(.horizontal, 16)
    }

    private func badge(_ text: String, system: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: system).imageScale(.small)
            Text(text)
                .font(.subheadline)
                .lineLimit(1)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(.white.opacity(0.15))
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }
}
