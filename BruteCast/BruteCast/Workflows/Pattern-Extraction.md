# Pattern Extraction Workflow

## When to Extract a Pattern

After implementing any feature, ask these questions:

- [ ] Did I write similar code before?
- [ ] Will I write similar code again?
- [ ] Does this solve a common problem?
- [ ] Can this be tested independently?

**If ≥3 yes answers:** Extract as a pattern.

---

## Extraction Process

### Step 1: Identify the Pattern

Look for:
- Repeated code blocks across files
- General-purpose algorithms
- Reusable async patterns
- Data transformation logic
- Common test utilities

### Step 2: Design the API

**Principles:**
- **Simple** - Easy to understand and use
- **Focused** - Does one thing well
- **Testable** - Can be tested in isolation
- **Generic** - Works for multiple use cases (use generics if applicable)

**Example:**
```swift
// Good: Generic and focused
struct TimeBasedFiltering {
    static func filter<T: TimeFilterable>(_ items: [T], in range: TimeRange) -> [T]
}

// Bad: Too specific
struct WeatherTimeFiltering {
    static func filterWeather(_ weather: [HourlyWeather], hours: Int) -> [HourlyWeather]
}
```

### Step 3: Write Tests First

Create test file in `BruteCastTests/PatternTests/`:

```swift
import XCTest
@testable import BruteCast

final class YourPatternTests: XCTestCase {

    func testPattern_WithNormalInput_ProducesExpectedOutput() {
        // Test normal case
    }

    func testPattern_WithEdgeCase_HandlesGracefully() {
        // Test edge cases
    }

    func testPattern_WithInvalidInput_ThrowsError() {
        // Test error cases
    }
}
```

**Coverage target:** 100% for patterns

### Step 4: Implement the Pattern

Create file in `BruteCast/Patterns/[Category]/`:

```swift
import Foundation

/// [One-sentence purpose]
///
/// **When to use:**
/// - [Criterion 1]
/// - [Criterion 2]
///
/// **When NOT to use:**
/// - [Anti-pattern 1]
/// - [Alternative: Use X instead when...]
///
/// **Example:**
/// ```swift
/// let result = YourPattern.doSomething(input)
/// ```
struct YourPattern {
    // Implementation
}
```

### Step 5: Test Reliability

Run tests 10 times:
```bash
for i in {1..10}; do
  echo "Run $i/10"
  xcodebuild test -only-testing:BruteCastTests/YourPatternTests
done
```

**Target:** ≥9/10 passes

If <9/10, iterate on implementation.

### Step 6: Document in Catalog

Add entry to `BruteCast/Patterns/README.md`:

```markdown
#### YourPattern
**Location:** `BruteCast/Patterns/Category/YourPattern.swift`
**Tests:** `BruteCastTests/PatternTests/YourPatternTests.swift`
**Reliability:** N/10 ✓

**Purpose:** [One sentence]

**When to use:**
- [Use case 1]
- [Use case 2]

**When NOT to use:**
- [Anti-pattern]

**Example:**
```swift
[Concrete usage code]
```
```

### Step 7: Refactor Existing Code

Find existing code that could use this pattern:

```bash
grep -r "similar_code_pattern" BruteCast/
```

Refactor to use the new pattern, run tests to verify.

### Step 8: Commit

```bash
git add BruteCast/Patterns/ BruteCastTests/PatternTests/ BruteCast/Patterns/README.md
git commit -m "feat: Extract YourPattern for [purpose]

Reliability: N/10
Use for: [use cases]"
```

---

## Pattern Categories

Choose the right category:

| Category | Examples |
|----------|----------|
| **AsyncPatterns/** | DebouncedTask, ConcurrentFetch, RetryWithBackoff |
| **DataPatterns/** | TimeBasedFiltering, MockDataGenerator, Aggregation |
| **ViewPatterns/** | LoadingState, ErrorDisplay, EmptyState |
| **TestingPatterns/** | ReliabilityRunner, AsyncTestHelpers, MockGenerators |

Create new categories as needed.

---

## Red Flags (Don't Extract These)

| Anti-Pattern | Why |
|--------------|-----|
| One-off logic | Not reusable |
| Highly coupled to specific feature | Too specific |
| Trivial wrappers | No value added |
| Unstable API (likely to change) | Wait until stable |

---

## Example: Extracting DebouncedTask

### Original Code (CitySearchViewModel.swift)

```swift
class CitySearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    private var searchTask: Task<Void, Never>?

    init() {
        $searchQuery.sink { [weak self] query in
            self?.searchTask?.cancel()
            self?.searchTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                await self?.performSearch(query)
            }
        }
    }
}
```

### Identified Pattern

**Similar code in:** ColorPickerView (debouncing color changes)

**Common problem:** Debouncing rapid user input

**Generic solution:** DebouncedTask pattern

### Extracted Pattern

```swift
@MainActor
final class DebouncedTask<Value> {
    private let delay: TimeInterval
    private let operation: @MainActor (Value) async throws -> Void
    private var currentTask: Task<Void, Never>?

    func submit(_ value: Value) {
        currentTask?.cancel()
        currentTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            if !Task.isCancelled {
                try? await operation(value)
            }
        }
    }
}
```

### Refactored Usage

```swift
class CitySearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    private let searchTask: DebouncedTask<String>

    init() {
        searchTask = DebouncedTask(delay: 0.3) { [weak self] query in
            await self?.performSearch(query)
        }

        $searchQuery.sink { [weak self] in
            self?.searchTask.submit($0)
        }
    }
}
```

**Result:** Cleaner code, reusable pattern, fully tested.

---

## Summary

| Step | Action | Output |
|------|--------|--------|
| 1 | Identify pattern | Use-case description |
| 2 | Design API | Function signatures |
| 3 | Write tests | Test file with 100% coverage |
| 4 | Implement | Pattern file with docs |
| 5 | Test reliability | 9/10+ passes |
| 6 | Document | Entry in Patterns/README.md |
| 7 | Refactor existing code | Cleaner codebase |
| 8 | Commit | Git history |

**Remember:** Patterns are investments. Extract thoughtfully, test thoroughly, document clearly.
