import XCTest
@testable import BruteCast

final class AlertServiceTests: XCTestCase {
    var sut: AlertService!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        sut = AlertService(session: .mock)
    }

    override func tearDown() {
        sut = nil
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testFetchAlertsForNonUSCity() async throws {
        // Given
        let city = MockCities.tokyo

        // When
        let result = try await sut.fetchAlerts(for: city)

        // Then
        XCTAssertTrue(result.alerts.isEmpty)
        XCTAssertEqual(result.city.id, city.id)
    }

    func testAlertSeverityPriority() {
        XCTAssertGreaterThan(AlertSeverity.extreme.priority, AlertSeverity.severe.priority)
        XCTAssertGreaterThan(AlertSeverity.severe.priority, AlertSeverity.moderate.priority)
        XCTAssertGreaterThan(AlertSeverity.moderate.priority, AlertSeverity.minor.priority)
        XCTAssertGreaterThan(AlertSeverity.minor.priority, AlertSeverity.unknown.priority)
    }

    func testAlertAffectedGraphType() {
        // Wind-related alerts
        let windAlert = WeatherAlert(
            id: "1",
            headline: "Wind Advisory",
            event: "Wind Advisory",
            severity: .moderate,
            certainty: "Likely",
            urgency: "Expected",
            onset: Date(),
            expires: Date(),
            description: "",
            instruction: nil,
            areaDesc: "",
            senderName: ""
        )
        XCTAssertEqual(windAlert.affectedGraphType, .wind)

        // Temperature-related alerts
        let coldAlert = WeatherAlert(
            id: "2",
            headline: "Extreme Cold Watch",
            event: "Extreme Cold Watch",
            severity: .extreme,
            certainty: "Likely",
            urgency: "Expected",
            onset: Date(),
            expires: Date(),
            description: "",
            instruction: nil,
            areaDesc: "",
            senderName: ""
        )
        XCTAssertEqual(coldAlert.affectedGraphType, .temperature)

        // Precipitation-related alerts
        let floodAlert = WeatherAlert(
            id: "3",
            headline: "Flash Flood Warning",
            event: "Flash Flood Warning",
            severity: .severe,
            certainty: "Likely",
            urgency: "Immediate",
            onset: Date(),
            expires: Date(),
            description: "",
            instruction: nil,
            areaDesc: "",
            senderName: ""
        )
        XCTAssertEqual(floodAlert.affectedGraphType, .precipitation)
    }

    func testAlertIsActive() {
        let now = Date()
        let past = Calendar.current.date(byAdding: .hour, value: -2, to: now)!
        let future = Calendar.current.date(byAdding: .hour, value: 2, to: now)!
        let farFuture = Calendar.current.date(byAdding: .hour, value: 4, to: now)!

        // Active alert (onset in past, expires in future)
        let activeAlert = WeatherAlert(
            id: "1",
            headline: "Test",
            event: "Test",
            severity: .moderate,
            certainty: "Likely",
            urgency: "Expected",
            onset: past,
            expires: future,
            description: "",
            instruction: nil,
            areaDesc: "",
            senderName: ""
        )
        XCTAssertTrue(activeAlert.isActive)

        // Expired alert
        let expiredAlert = WeatherAlert(
            id: "2",
            headline: "Test",
            event: "Test",
            severity: .moderate,
            certainty: "Likely",
            urgency: "Expected",
            onset: past,
            expires: past,
            description: "",
            instruction: nil,
            areaDesc: "",
            senderName: ""
        )
        XCTAssertFalse(expiredAlert.isActive)

        // Future alert (not yet active)
        let futureAlert = WeatherAlert(
            id: "3",
            headline: "Test",
            event: "Test",
            severity: .moderate,
            certainty: "Likely",
            urgency: "Expected",
            onset: future,
            expires: farFuture,
            description: "",
            instruction: nil,
            areaDesc: "",
            senderName: ""
        )
        XCTAssertFalse(futureAlert.isActive)
    }
}
