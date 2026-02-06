# BruteCast Patterns Library

Reusable patterns extracted from implementations following Compounding Vibe Coding methodology.

## Philosophy

Before implementing, check this catalog. If a pattern exists, use it. After implementing, extract reusable patterns here.

Every pattern includes:
- **When to use** - Clear applicability criteria
- **When NOT to use** - Anti-patterns and alternatives
- **Example** - Concrete usage code
- **Tests** - Comprehensive test coverage
- **Reliability** - Verified consistency

---

## Available Patterns

### Async Patterns

#### DebouncedTask
**Location:** `BruteCast/Patterns/AsyncPatterns/DebouncedTask.swift`
**Tests:** `BruteCastTests/PatternTests/DebouncedTaskTests.swift`
**Reliability:** 10/10

**Purpose:** Delays execution of rapid-fire async operations until activity settles.

**When to use:**
- Search fields triggering API calls
- User input triggering expensive operations
- Coalescing rapid-fire events

**When NOT to use:**
- Immediate feedback required
- One-time operations
- Operations that must execute every time

**Example:**
```swift
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    private let searchTask: DebouncedTask<String>

    init() {
        searchTask = DebouncedTask(delay: 0.3) { [weak self] query in
            await self?.performSearch(query)
        }

        $searchText.sink { [weak self] text in
            self?.searchTask.submit(text)
        }
    }
}
```

**Alternative:** Use Combine's `.debounce()` if working purely with publishers.

---

### Data Patterns

#### MockDataGenerator
**Location:** `BruteCast/Mocks/Patterns/MockDataGenerator.swift`
**Tests:** `BruteCastTests/PatternTests/MockDataGeneratorTests.swift`
**Reliability:** 10/10

**Purpose:** Generate realistic mock data for tests and previews.

**When to use:**
- Creating test data that mimics real-world patterns
- Seeding UI previews with believable data
- Performance testing with realistic datasets

**When NOT to use:**
- Need exact/deterministic values for assertions
- Testing edge cases (use explicit values)

**Methods available:**
- `sinusoidalCurve()` - Daily cycles (temperature, traffic, user activity)
- `randomWalk()` - Incrementally changing values (stock prices, sensor drift)
- `linearInterpolation()` - Smooth transitions between points

**Example:**
```swift
let temperatures = MockDataGenerator.sinusoidalCurve(
    count: 24,
    baseline: 65.0,
    amplitude: 15.0,
    peakOffset: 14  // 2 PM
)
```

---

#### TimeBasedFiltering
**Location:** `BruteCast/Patterns/DataPatterns/TimeBasedFiltering.swift`
**Tests:** `BruteCastTests/PatternTests/TimeBasedFilteringTests.swift`
**Reliability:** 10/10

**Purpose:** Filter time-series data by time ranges.

**When to use:**
- Weather data time windows
- Event filtering by date range
- Time-windowed data analysis

**When NOT to use:**
- Single date lookups (use dictionary)
- Non-temporal filtering

**Example:**
```swift
let next12Hours = TimeRange.hours(from: Date(), hours: 12)
let filtered = TimeBasedFiltering.filter(weatherData, in: next12Hours)
```

**Protocol conformance:**
```swift
extension YourType: TimeFilterable {
    var timestamp: Date { yourDateProperty }
}
```

---

## Reliability Metrics

All patterns tested for consistency:

| Pattern | Reliability | Type | Status |
|---------|-------------|------|--------|
| DebouncedTask | 10/10 | Async | ✓ |
| MockDataGenerator | 10/10 | Deterministic | ✓ |
| TimeBasedFiltering | 10/10 | Deterministic | ✓ |

**Target:** ≥9/10 for all patterns (90% threshold)

---

## Pattern Categories

- **AsyncPatterns/** - Async/await, concurrency, Task management
- **DataPatterns/** - Data manipulation, filtering, transformation
- **TestingPatterns/** - Test helpers, mocks, utilities (ReliabilityRunner, AsyncTestHelpers)

---

## Adding New Patterns

### Extraction Checklist

After implementing a feature, ask:
- [ ] Did I write similar code before?
- [ ] Will I write similar code again?
- [ ] Does this solve a common problem?
- [ ] Can this be tested independently?

If ≥3 yes: Extract as pattern.

### Process

1. Create pattern file in appropriate category
2. Write comprehensive tests (100% coverage target)
3. Update this README with pattern entry
4. Refactor existing code to use pattern
5. Document when to use and alternatives

---

## Questions?

See `BruteCast/Workflows/` for development workflows and TDD cycle documentation.
