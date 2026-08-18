//
//  TMDBSwiftUIUITests.swift
//  TMDBSwiftUIUITests
//

import XCTest

/// Sanity check for the harness itself: the app launches under `-uitest` and reaches Home
/// without hanging on the splash screen or an unstubbed network request.
final class TMDBSwiftUIUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesToHomeUnderUITest() {
        let app = UITestApp.launch()
        app.navigationBars["Home"].awaitExistence()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            UITestApp.launch()
        }
    }
}
