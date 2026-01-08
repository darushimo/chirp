import XCTest
@testable import BruteCast

final class GeocodingServiceTests: XCTestCase {
    var sut: GeocodingService!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        sut = GeocodingService(session: .mock)
    }

    override func tearDown() {
        sut = nil
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testSearchCitiesSuccess() async throws {
        // Given
        let mockResponse = """
        {
            "results": [
                {
                    "id": 5128581,
                    "name": "New York",
                    "latitude": 40.7128,
                    "longitude": -74.006,
                    "country": "United States",
                    "admin1": "New York",
                    "timezone": "America/New_York"
                },
                {
                    "id": 5128582,
                    "name": "New York Mills",
                    "latitude": 46.518,
                    "longitude": -95.3758,
                    "country": "United States",
                    "admin1": "Minnesota",
                    "timezone": "America/Chicago"
                }
            ]
        }
        """.data(using: .utf8)!

        let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=new%20york&count=10&language=en&format=json")!

        MockURLProtocol.mockResponses[url] = (
            mockResponse,
            HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            nil
        )

        // When
        let results = try await sut.searchCities(query: "new york")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "New York")
        XCTAssertEqual(results[0].state, "New York")
        XCTAssertEqual(results[0].country, "United States")
    }

    func testSearchCitiesEmptyQuery() async throws {
        // When
        let results = try await sut.searchCities(query: "")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchCitiesWhitespaceQuery() async throws {
        // When
        let results = try await sut.searchCities(query: "   ")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchCitiesNoResults() async throws {
        // Given
        let mockResponse = """
        {
            "results": null
        }
        """.data(using: .utf8)!

        let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=xyznonexistent&count=10&language=en&format=json")!

        MockURLProtocol.mockResponses[url] = (
            mockResponse,
            HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            nil
        )

        // When
        let results = try await sut.searchCities(query: "xyznonexistent")

        // Then
        XCTAssertTrue(results.isEmpty)
    }
}
