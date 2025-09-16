//
//  RickAndMortyAssignmentApp.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 12/09/2025.
//

import BackgroundTasks
import SwiftData
import SwiftUI

@main
struct RickAndMortyAssignmentApp: App {
    let modelContainer: ModelContainer
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var dependencyContainer: AppContainer

    private let episodesRefreshTaskId = "com.example.ram.episodesRefresh"

    private let refresher: EpisodesBackgroundRefresher

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

        self.refresher = EpisodesBackgroundRefresher(episodesService: dependencyContainer.episodeSyncService)
    }

    var body: some Scene {
        WindowGroup {
            RMCoordinatorView(coordinator: dependencyContainer.coordinator)
        }
        .modelContainer(modelContainer)
        // NOTE: does not work in the sim
        .backgroundTask(.appRefresh(episodesRefreshTaskId)) {
            await refresher.performRefresh()
            await scheduleEpisodesBackgroundRefresh()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                scheduleEpisodesBackgroundRefresh()
            }
        }
    }

    private func scheduleEpisodesBackgroundRefresh() {
        let id = episodesRefreshTaskId
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            guard !requests.contains(where: { $0.identifier == id }) else {
                print("BG refresh already scheduled")
                return
            }

            let request = BGAppRefreshTaskRequest(identifier: id)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)

            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("BG submit failed: \(error)")
            }
        }
    }
}
