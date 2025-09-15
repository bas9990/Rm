//
//  CharacterTile.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct CharacterTile: View {
    let character: CharacterEntity
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: character.imageURLString.flatMap(URL.init(string:))) { phase in
                    switch phase {
                    case .empty:
                        ZStack { Color.gray.opacity(0.12)
                            ProgressView()
                        }
                    case let .success(image):
                        image.resizable().scaledToFill()
                    case .failure:
                        ZStack { Color.gray.opacity(0.12)
                            Image(systemName: "person")
                        }
                    @unknown default:
                        Color.gray.opacity(0.12)
                    }
                }
                .frame(height: 140)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(character.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(character.status) • \(character.species)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text("Origin: \(character.originName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text("Episodes: \(character.episodeCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}
