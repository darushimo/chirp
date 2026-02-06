# BruteCast Development Workflows

Documented approaches for common development tasks following Compounding Vibe Coding methodology.

## Purpose

These workflows capture **HOW** we build features, not just **WHAT** we build. Follow them for consistency and quality.

---

## Available Workflows

### [TDD-Cycle.md](TDD-Cycle.md)
**Use for:** Every feature implementation

**Phases:** RED → GREEN → REFACTOR → VALIDATE

Learn the discipline of test-first development with reliability validation.

---

### [Pattern-Extraction.md](Pattern-Extraction.md)
**Use for:** After implementing any feature

Identify, extract, test, and document reusable patterns. Build a library of proven solutions.

---

## Core Principles

### Test-Driven Development
- **Write tests first** - Define behavior before implementation
- **Red, Green, Refactor** - Fail, pass, improve
- **Reliability validation** - Run tests 10x for async features (≥9/10 passes)

### Compounding Engineering
- **Extract patterns** - Build reusable libraries from implementations
- **Document patterns** - Capture when/why to use them
- **Iterate on reliability** - Aim for >90% success rate

### Quality Standards
- No feature is complete without tests
- Tests must pass reliably (>90% for async/AI features)
- Every significant implementation should produce a documented pattern
- Patterns should be specific enough to reuse, general enough to adapt

---

## Quick Reference

### Starting a New Feature

1. Check `BruteCast/Patterns/README.md` for applicable patterns
2. If none exist, plan to extract one afterward
3. Follow `TDD-Cycle.md`:
   - RED: Write failing test
   - GREEN: Make it pass
   - REFACTOR: Extract patterns
   - VALIDATE: Run full suite + reliability check

### Completing a Feature

1. Follow `Pattern-Extraction.md` checklist
2. Update `Patterns/README.md` if pattern extracted
3. Verify ≥9/10 reliability for async features
4. Commit with clear message

---

## Communication Protocol

### Your Responsibilities (Human)
- Define what success looks like with concrete examples
- Provide sample data demonstrating desired behavior
- Review and approve designs before implementation
- Decide when a feature is "good enough" to ship
- Give feedback on what's working and what needs improvement
- Approve patterns before they're codified for reuse

### AI Responsibilities (Claude)
- Write all tests before writing implementation code
- Follow TDD cycle strictly (RED → GREEN → REFACTOR → VALIDATE)
- Iterate on solutions until tests reliably pass
- Run tests multiple times and analyze failures
- Extract reusable patterns from each implementation
- Document workflows for future reference
- Propose designs and wait for approval before proceeding

---

## File Structure

```
BruteCast/
├── Patterns/           # Extracted reusable patterns
│   ├── README.md       # Pattern catalog
│   ├── AsyncPatterns/
│   ├── DataPatterns/
│   └── TestingPatterns/
├── Workflows/          # This directory
│   ├── README.md
│   ├── TDD-Cycle.md
│   └── Pattern-Extraction.md
└── [App code...]

BruteCastTests/
├── PatternTests/       # Tests for extracted patterns
├── TestHelpers/        # Reusable test utilities
└── [Feature tests...]
```

---

## Tools

### ReliabilityRunner
Location: `BruteCastTests/TestHelpers/ReliabilityRunner.swift`

Run tests N times to measure reliability:
```swift
let result = await ReliabilityRunner.run(iterations: 10) {
    try await yourAsyncTest()
}
print(result.summary) // Success rate, pass/fail count
```

### AsyncTestHelpers
Location: `BruteCastTests/TestHelpers/AsyncTestHelpers.swift`

Convert publishers to async for testing:
```swift
let value = try await publisher.async()
```

---

## Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Test coverage | >80% | Track per feature |
| Pattern reliability | ≥9/10 | Per pattern |
| AI feature reliability | ≥9/10 initially, higher over time | Per feature |
| Patterns extracted | 1+ per major feature | Track in README |

---

## Questions?

Refer to specific workflow documents for detailed steps.
