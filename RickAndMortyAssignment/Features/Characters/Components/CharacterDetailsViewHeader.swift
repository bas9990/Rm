//
//  CharacterDetailsViewHeader.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct CharacterDetailsViewHeader: View {
    let imageURL: URL?
    let name: String
    let status: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        LinearGradient(colors: [.rmBlue, .rmYellow], startPoint: .top, endPoint: .bottom)
                        ProgressView()
                    }
                case let .success(image):
                    image.resizable().scaledToFill()
                case .failure:
                    LinearGradient(colors: [.rmBlue, .rmYellow], startPoint: .top, endPoint: .bottom)
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(height: 260)
            .frame(maxWidth: .infinity)
            .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.55)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 140)
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 10) {
                IsAliveStatusPill(status: status)
                Text(name)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 6, y: 2)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.bottom, 18)
            .padding(.horizontal, 16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
    }
}
