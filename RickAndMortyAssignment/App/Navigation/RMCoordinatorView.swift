//
//  RMCoordinatorView.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 15/09/2025.
//

import SwiftUI

struct RMCoordinatorView: View {
    @ObservedObject var coordinator: RMCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .dashboard)
                .navigationDestination(for: RMPage.self) { page in
                    coordinator.build(page: page)
                }
        }
    }
}
