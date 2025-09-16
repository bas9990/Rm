//
//  LocationsListView.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

import SwiftUI

struct LocationsListView: View {
    @StateObject private var viewModel: LocationsViewModel

    init(repository: LocationsRepository) {
        _viewModel = StateObject(wrappedValue: LocationsViewModel(repository: repository))
    }

    var body: some View {
        List {
            ForEach(viewModel.locations) { location in
                LocationRow(location: location)
            }

            footer
        }
        .navigationTitle("Locations")
        .refreshable { await viewModel.refreshFromStart() }
        .task { await viewModel.loadFirst() }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK", role: .cancel) { /* dismiss */ }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    @ViewBuilder
    private var footer: some View {
        if viewModel.hasReachedEnd {
            HStack {
                Spacer()
                Text("You reached the end. \(viewModel.locations.count)")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        } else if !viewModel.locations.isEmpty {
            LoadMoreTrigger(isLoading: viewModel.isLoading) {
                await viewModel.loadMoreIfNeeded()
            }
        }
    }
}

#Preview {
    LocationsListView(repository: RemoteLocationsRepository(apiClient: RMAPIClient()))
}
