import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [City] = []
    @Published var isSearching: Bool = false
    @Published var error: Error?

    private let geocodingService: GeocodingServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init(geocodingService: GeocodingServiceProtocol = GeocodingService.shared) {
        self.geocodingService = geocodingService
        setupDebounce()
    }

    private func setupDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        searchTask?.cancel()

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        error = nil

        searchTask = Task {
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
    }

    func clear() {
        searchTask?.cancel()
        searchText = ""
        searchResults = []
        error = nil
        isSearching = false
    }
}
