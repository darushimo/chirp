import Foundation

@MainActor
final class DebouncedTask<Value> {
    private let delay: TimeInterval
    private let operation: @Sendable (Value) async -> Void
    private var task: Task<Void, Never>?

    init(delay: TimeInterval, operation: @escaping @Sendable (Value) async -> Void) {
        self.delay = delay
        self.operation = operation
    }

    func submit(_ value: Value) {
        task?.cancel()

        task = Task {
            try? await Task.sleep(for: .seconds(delay))

            guard !Task.isCancelled else { return }

            await operation(value)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
