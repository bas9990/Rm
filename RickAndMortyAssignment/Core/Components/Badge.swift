//
//  Badge.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct Badge: View {
    let text: String
    var systemImage: String?

    let foreground: Color
    let background: Color
    private let font: Font = .subheadline
    private let horizontalPadding: CGFloat = 10
    private let verticalPadding: CGFloat = 6
    private let iconScale: Image.Scale = .small

    init(
        text: String,
        systemImage: String? = nil,
        foreground: Color = .white,
        background: Color = .white.opacity(0.15)
    ) {
        self.text = text
        self.systemImage = systemImage
        self.foreground = foreground
        self.background = background
    }

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage).imageScale(iconScale)
            }
            Text(text)
                .font(font)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(Capsule())
    }
}
