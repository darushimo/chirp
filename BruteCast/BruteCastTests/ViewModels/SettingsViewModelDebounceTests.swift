import XCTest
import Combine
@testable import BruteCast

@MainActor
final class SettingsViewModelDebounceTests: XCTestCase {

    func testThemeColorUpdate_WithRapidChanges_DebouncesUpdate() async throws {
        // Arrange
        let viewModel = SettingsViewModel()
        let initialTheme = viewModel.currentTheme

        // Track actual theme updates (not individual color changes)
        var updateCount = 0
        let cancellable = viewModel.$currentTheme
            .dropFirst()
            .sink { _ in updateCount += 1 }

        // Act - simulate rapid color picker changes (user dragging color picker)
        viewModel.backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.1)
        viewModel.backgroundColor = Color(red: 0.2, green: 0.2, blue: 0.2)
        viewModel.backgroundColor = Color(red: 0.3, green: 0.3, blue: 0.3)

        // Wait less than debounce delay - should not update yet
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms < 100ms debounce

        let midUpdateCount = updateCount

        // Wait for debounce to complete
        try await Task.sleep(nanoseconds: 150_000_000) // Additional 150ms = 200ms total

        // Assert
        // During debounce period, should have fewer updates
        XCTAssertLessThan(midUpdateCount, 2, "Should not update theme during debounce period")

        // After debounce, should have received the final update
        XCTAssertGreaterThan(updateCount, 0, "Should receive theme update after debounce")
        XCTAssertLessThan(updateCount, 3, "Should debounce rapid color changes (not 1:1 updates)")

        cancellable.cancel()
    }

    func testThemeColorUpdate_WithMultipleColorChanges_CombinesIntoSingleUpdate() async throws {
        // Arrange
        let viewModel = SettingsViewModel()

        var updateCount = 0
        let cancellable = viewModel.$currentTheme
            .dropFirst()
            .sink { _ in updateCount += 1 }

        // Act - change multiple colors rapidly (like adjusting multiple properties in UI)
        viewModel.backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.1)
        viewModel.textColor = Color(red: 0.9, green: 0.9, blue: 0.9)
        viewModel.temperatureColor = Color(red: 1.0, green: 0.5, blue: 0.0)

        // Wait for debounce
        try await Task.sleep(nanoseconds: 200_000_000) // 200ms

        // Assert - should combine all 3 color changes into single theme update
        XCTAssertEqual(updateCount, 1, "Should combine multiple color changes into single debounced update")

        cancellable.cancel()
    }

    func testPresetThemeSelection_UpdatesImmediately_WithoutDebounce() async throws {
        // Arrange
        let viewModel = SettingsViewModel()

        var updateCount = 0
        let cancellable = viewModel.$currentTheme
            .dropFirst()
            .sink { _ in updateCount += 1 }

        // Act - select preset theme (should bypass debouncing)
        viewModel.selectPresetTheme(.cyberpunk)

        // No wait needed - preset selection is immediate
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms

        // Assert - preset selection should update immediately
        XCTAssertEqual(updateCount, 1, "Preset theme selection should update immediately")
        XCTAssertEqual(viewModel.currentTheme.id, Theme.cyberpunk.id, "Should have cyberpunk theme")

        cancellable.cancel()
    }
}
