//
//  IsAliveStatusPill.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct IsAliveStatusPill: View {
    let status: String
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(dotColor).frame(width: 8, height: 8)
            Text(status.capitalized.isEmpty ? "Unknown" : status.capitalized)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.18))
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }

    private var dotColor: Color {
        switch status.lowercased() {
        case "alive": .green
        case "dead": .red
        default: .gray
        }
    }
}
