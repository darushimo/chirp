import Foundation
import Combine

protocol GeocodingServiceProtocol {
    func searchCities(query: String) async throws -> [City]
}

final class GeocodingService: GeocodingServiceProtocol {
    static let shared = GeocodingService()

    private let session: URLSession
    private let baseURL = "https://geocoding-api.open-meteo.com/v1/search"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchCities(query: String) async throws -> [City] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components.url else {
            throw GeocodingServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GeocodingServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return parseCities(from: decoded)
    }

    private func parseCities(from response: GeocodingResponse) -> [City] {
        guard let results = response.results else { return [] }

        return results.map { result in
            City(
                name: result.name,
                state: result.admin1,
                country: result.country,
                latitude: result.latitude,
                longitude: result.longitude,
                timezone: result.timezone
            )
        }
    }
}

enum GeocodingServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from geocoding service"
        case .noResults:
            return "No cities found"
        }
    }
}

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?

    struct GeocodingResult: Codable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String
        let admin1: String?
        let timezone: String
    }
}

final class DebouncedCitySearch: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [City] = []
    @Published var isSearching: Bool = false
    @Published var error: Error?

    private var cancellables = Set<AnyCancellable>()
    private let geocodingService: GeocodingServiceProtocol

    init(geocodingService: GeocodingServiceProtocol = GeocodingService.shared) {
        self.geocodingService = geocodingService
        setupDebounce()
    }

    private func setupDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task {
                    await self?.search(query: query)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func search(query: String) async {
        guard !query.isEmpty else {
            results = []
            return
        }

        isSearching = true
        error = nil

        do {
            results = try await geocodingService.searchCities(query: query)
        } catch {
            self.error = error
            results = []
        }

        isSearching = false
    }

    func clear() {
        searchText = ""
        results = []
        error = nil
    }
}
