//
//  LocationsViewModelTests.swift
//  RickAndMortyAssignment
//
//  Created by Bas Hogeveen on 16/09/2025.
//

@testable import RickAndMortyAssignment
import XCTest

@MainActor
final class LocationsViewModelTests: XCTestCase {
    func testLoadFirst_success_setsItemsAndNext() async {
        // Arrange
        let repo = MockLocationsRepository()
        let page1Items = [makeLocation(1), makeLocation(2)]
        let page2URL = URL(string: "https://rickandmortyapi.com/api/location?page=2")!
        repo.stub(.page(1), items: page1Items, next: .url(page2URL))

        let viewModel = LocationsViewModel(repository: repo)

        // Act
        await viewModel.loadFirst()

        // Assert
        XCTAssertEqual(viewModel.locations.map(\.id), [1, 2])
        XCTAssertFalse(viewModel.hasReachedEnd)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(repo.callCount, 1)
    }

    func testLoadMore_appendsItems_andReachesEndWhenNoNext() async {
        // Arrange
        let repo = MockLocationsRepository()
        let page1Items = [makeLocation(1), makeLocation(2)]
        let page2URL = URL(string: "https://rickandmortyapi.com/api/location?page=2")!
        repo.stub(.page(1), items: page1Items, next: .url(page2URL))

        let page2Items = [makeLocation(3)]
        repo.stub(.url(page2URL), items: page2Items, next: nil)

        let viewModel = LocationsViewModel(repository: repo)

        // Act
        await viewModel.loadFirst() // sets next to page2
        await viewModel.loadMoreIfNeeded() // consumes page2

        // Assert
        XCTAssertEqual(viewModel.locations.map(\.id), [1, 2, 3])
        XCTAssertTrue(viewModel.hasReachedEnd)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(repo.callCount, 2)
    }

    func testRefreshFromStart_replacesItems() async {
        // Arrange
        let repo = MockLocationsRepository()
        // initial load
        let page1Old = [makeLocation(1), makeLocation(2)]
        repo.stub(.page(1), items: page1Old, next: nil)

        let viewModel = LocationsViewModel(repository: repo)
        await viewModel.loadFirst()
        XCTAssertEqual(viewModel.locations.map(\.id), [1, 2])

        // Re-stub page 1 to simulate updated data
        let page1New = [makeLocation(10), makeLocation(11), makeLocation(12)]
        repo.stub(.page(1), items: page1New, next: nil)

        // Act
        await viewModel.refreshFromStart()

        // Assert
        XCTAssertEqual(viewModel.locations.map(\.id), [10, 11, 12])
        XCTAssertTrue(viewModel.hasReachedEnd)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(repo.callCount, 2) // once for first load, once for refresh
    }

    func testLoadFirst_error_setsErrorMessage() async {
        // Arrange
        let repo = MockLocationsRepository()
        repo.stubError(.page(1), error: TestError.forced)

        let viewModel = LocationsViewModel(repository: repo)

        // Act
        await viewModel.loadFirst()

        // Assert
        XCTAssertTrue(viewModel.locations.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(repo.callCount, 1)
    }

    func testIsLoadingGuard_preventsOverlappingLoads() async {
        // Arrange
        let repo = MockLocationsRepository()
        let page1Items = [makeLocation(1)]
        repo.stub(.page(1), items: page1Items, next: nil)
        // Make the repository slow so the second call overlaps
        repo.artificialDelay = 0.2

        let viewModel = LocationsViewModel(repository: repo)

        // Act: fire two concurrent first loads
        async let firstLoadOne: Void = viewModel.loadFirst()
        async let firstLoadTwo: Void = viewModel.loadFirst()
        _ = await (firstLoadOne, firstLoadTwo)

        // Assert: only one call should have been made because of the isLoading guard
        XCTAssertEqual(repo.callCount, 1)
        XCTAssertEqual(viewModel.locations.map(\.id), [1])
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}

private func makeLocation(_ id: Int, name: String? = nil) -> Location {
    Location(
        id: id,
        name: name ?? "Location \(id)",
        type: "Planet",
        dimension: "Dimension C-137",
        residentIDs: [],
        residentCount: 0
    )
}
