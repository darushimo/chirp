import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [City] = []
    @Published var isSearching: Bool = false
    @Published var error: Error?

    private let geocodingService: GeocodingServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private lazy var searchTask: DebouncedTask<String> = {
        DebouncedTask(delay: 0.3) { [weak self] query in
            await self?.performSearch(query: query)
        }
    }()

    init(geocodingService: GeocodingServiceProtocol = GeocodingService.shared) {
        self.geocodingService = geocodingService

        // Subscribe to searchText changes and submit to DebouncedTask
        $searchText
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchTask.submit(query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        error = nil

        do {
            let results = try await geocodingService.searchCities(query: query)
            if !Task.isCancelled {
                searchResults = results
            }
        } catch {
            if !Task.isCancelled {
                self.error = error
                searchResults = []
            }
        }
        if !Task.isCancelled {
            isSearching = false
        }
    }

    func clear() {
        searchTask.cancel()
        searchText = ""
        searchResults = []
        error = nil
        isSearching = false
    }
}
