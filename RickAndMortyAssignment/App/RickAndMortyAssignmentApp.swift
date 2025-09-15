//
//  RickAndMortyAssignmentApp.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 12/09/2025.
//

import SwiftData
import SwiftUI

@main
struct RickAndMortyAssignmentApp: App {
    let modelContainer: ModelContainer

    @StateObject private var dependencyContainer: AppContainer

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainerProvider.make()
        } catch {
            #if DEBUG
                fatalError("ModelContainer init failed: \(error)")
            #endif
        }
        self.modelContainer = container

        let dependencyContainer = AppContainer(modelContainer: container)
        _dependencyContainer = StateObject(wrappedValue: dependencyContainer)
    }

    var body: some Scene {
        WindowGroup {
            RMCoordinatorView(coordinator: dependencyContainer.coordinator)
        }
        .modelContainer(modelContainer)
    }
}
