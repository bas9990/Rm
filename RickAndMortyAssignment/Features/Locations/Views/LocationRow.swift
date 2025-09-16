//
//  LocationRow.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import SwiftUI

struct LocationRow: View {
    let location: Location

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [.rmBlue, .rmMint],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                Image(systemName: "globe.americas.fill")
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(location.name).font(.headline)
                Text("\(location.type) • \(location.dimension)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "person.3").imageScale(.small)
                Text("\(location.residentCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
