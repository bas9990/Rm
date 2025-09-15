//
//  LoadMoreTrigger.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct LoadMoreTrigger: View {
    let isLoading: Bool
    let action: () async -> Void

    var body: some View {
        HStack {
            Spacer()
            ProgressView("Loading…")
            Spacer()
        }
        .onAppear {
            guard !isLoading else { return }
            Task { await action() }
        }
    }
}
