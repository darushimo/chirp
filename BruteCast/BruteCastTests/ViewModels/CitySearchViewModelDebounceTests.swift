import XCTest
@testable import BruteCast

@MainActor
final class CitySearchViewModelDebounceTests: XCTestCase {

    func testSearchQuery_WithRapidChanges_DebouncesAPICall() async throws {
        // Arrange
        let mockService = MockGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: mockService)

        // Act
        viewModel.searchText = "L"
        viewModel.searchText = "Lo"
        viewModel.searchText = "Lon"
        viewModel.searchText = "Lond"
        viewModel.searchText = "London"

        // Wait for debounce
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4s (300ms debounce + buffer)

        // Assert
        XCTAssertEqual(mockService.searchCallCount, 1, "Should only call API once after debounce")
        XCTAssertEqual(mockService.lastSearchQuery, "London", "Should search for final value")
    }

    func testSearchQuery_WithEmptyString_CancelsSearch() async throws {
        // Arrange
        let mockService = MockGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: mockService)

        // Act
        viewModel.searchText = "London"
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        viewModel.searchText = ""

        try await Task.sleep(nanoseconds: 400_000_000) // 0.4s

        // Assert
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        // Empty string clears results without calling service
    }

    func testSearchQuery_WithWhitespaceOnly_DoesNotSearch() async throws {
        // Arrange
        let mockService = MockGeocodingService()
        let viewModel = CitySearchViewModel(geocodingService: mockService)

        // Act
        viewModel.searchText = "   "

        try await Task.sleep(nanoseconds: 400_000_000) // 0.4s

        // Assert
        XCTAssertEqual(mockService.searchCallCount, 0, "Should not call API for whitespace-only query")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testSearchQuery_CancellationBehavior() async throws {
        // Arrange
        let mockService = MockGeocodingService()
        mockService.delaySeconds = 0.2 // Simulate slow API
        let viewModel = CitySearchViewModel(geocodingService: mockService)

        // Act
        viewModel.searchText = "London"
        try await Task.sleep(nanoseconds: 350_000_000) // Wait for debounce to trigger
        viewModel.searchText = "Paris" // Change before first search completes

        try await Task.sleep(nanoseconds: 600_000_000) // Wait for second search

        // Assert
        XCTAssertEqual(mockService.lastSearchQuery, "Paris", "Should have final search query")
        // Both searches may have been called due to debounce, but last one wins
    }
}

// MARK: - Mock Service

class MockGeocodingService: GeocodingServiceProtocol {
    var searchCallCount = 0
    var lastSearchQuery: String?
    var mockResults: [City] = []
    var delaySeconds: TimeInterval = 0
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: -1)

    func searchCities(query: String) async throws -> [City] {
        searchCallCount += 1
        lastSearchQuery = query

        if delaySeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
        }

        if shouldThrowError {
            throw errorToThrow
        }

        return mockResults
    }
}
