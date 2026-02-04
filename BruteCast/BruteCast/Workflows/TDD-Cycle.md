# TDD Cycle for BruteCast

## Overview

We follow strict Test-Driven Development with reliability validation.

**Phases:** RED → GREEN → REFACTOR → VALIDATE

**Goal:** Every feature is tested before implementation and passes reliably (≥90%).

---

## RED Phase: Write Failing Test

### Steps

1. Identify the behavior to test (one specific behavior per test)
2. Write the test in the appropriate test file
3. Run the test to verify it fails
4. Confirm failure message matches expectation

### Example

```swift
func testWeatherService_FetchWeather_ReturnsValidData() async throws {
    // Arrange
    let service = WeatherService()
    let city = City(id: "1", name: "Test", latitude: 0, longitude: 0, country: "US")

    // Act
    let weather = try await service.fetchWeather(for: city)

    // Assert
    XCTAssertFalse(weather.hourlyWeather.isEmpty)
}
```

Run:
```bash
xcodebuild test -only-testing:BruteCastTests/WeatherServiceTests/testWeatherService_FetchWeather_ReturnsValidData
```

Expected: **FAIL** - "Use of unresolved identifier 'WeatherService'"

### Commit

```bash
git add BruteCastTests/Services/WeatherServiceTests.swift
git commit -m "test: Add failing test for weather fetching"
```

---

## GREEN Phase: Make Test Pass

### Steps

1. Write **minimal** code to make test pass
2. Run test 10 times via ReliabilityRunner (if async/random behavior)
3. If <90% pass rate, iterate on implementation
4. For deterministic code, single pass is sufficient

### Example

```swift
class WeatherService {
    func fetchWeather(for city: City) async throws -> CityWeatherData {
        // Minimal implementation
        return CityWeatherData(
            city: city,
            hourlyWeather: [],
            alerts: []
        )
    }
}
```

Run reliability check (for async code):
```bash
for i in {1..10}; do
  echo "Run $i/10"
  xcodebuild test -only-testing:BruteCastTests/WeatherServiceTests
done
```

Expected: **9+ PASS** out of 10

### Commit

```bash
git add BruteCast/Services/WeatherService.swift BruteCastTests/Services/WeatherServiceTests.swift
git commit -m "feat: Implement weather fetching (9/10 passes)"
```

---

## REFACTOR Phase: Improve Code Quality

### Steps

1. Extract common patterns
2. Improve naming and structure
3. Reduce duplication
4. Run tests 10 more times to verify no regressions
5. Check pattern catalog for applicable patterns

### Guidelines

- **DRY** - Don't Repeat Yourself
- **YAGNI** - You Ain't Gonna Need It (no speculative code)
- Extract patterns if applicable (see `Pattern-Extraction.md`)

### Example

If multiple services have similar async fetching logic, extract it:
```swift
protocol AsyncFetchable {
    associatedtype Output
    func fetch() async throws -> Output
}
```

### Commit

```bash
git add BruteCast/Services/WeatherService.swift BruteCast/Patterns/
git commit -m "refactor: Extract AsyncFetchable pattern from WeatherService"
```

---

## VALIDATE Phase: Final Verification

### Steps

1. Run full test suite (not just new tests)
2. For critical features, run reliability test one more time
3. Verify no regressions
4. Update documentation if pattern was extracted

### Commands

Full test suite:
```bash
xcodebuild test -project BruteCast.xcodeproj -scheme BruteCast
```

Critical feature reliability (10x):
```bash
for i in {1..10}; do xcodebuild test -only-testing:BruteCastTests/YourCriticalTests; done
```

### Success Criteria

- [ ] All tests pass
- [ ] New feature passes ≥9/10 times (if async/AI)
- [ ] No regressions in existing tests
- [ ] Pattern extracted and documented (if applicable)

### Merge

Only merge when all criteria met.

---

## Special Cases

### AI Features

AI features often have non-deterministic behavior. Target 9/10 passes initially, but aim for higher over time.

**Example: Mood detection from text**
```swift
func testMoodDetection_FrustrationKeywords_DetectsFrustration() async throws {
    let text = "I'm so frustrated with this bug!"
    let mood = try await moodDetector.detect(text)
    XCTAssertEqual(mood, .frustrated)
}
```

Run 10x, expect ≥9 passes. If <9, iterate on prompt/logic.

### View Testing

Use snapshot testing for pixel-perfect views:
```swift
func testWeatherCard_DisplaysCorrectly() {
    let view = WeatherCardView(weather: mockWeather)
    assertSnapshot(matching: view, as: .image)
}
```

### Integration Tests

Test multiple components working together:
```swift
func testWeatherFlow_FetchAndDisplay_WorksEndToEnd() async throws {
    // Test service → ViewModel → View data flow
}
```

---

## Summary

| Phase | Action | Commit | Reliability Check |
|-------|--------|--------|-------------------|
| RED | Write failing test | Yes | No |
| GREEN | Make test pass | Yes | 10x for async |
| REFACTOR | Extract patterns | Yes | 10x after changes |
| VALIDATE | Full suite + final check | Merge | 10x for critical |

**Remember:** Tests first, code second, patterns always.
