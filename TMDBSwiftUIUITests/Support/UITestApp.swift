//
//  UITestApp.swift
//  TMDBSwiftUIUITests
//

import XCTest

/// Shared launch helper and small XCUIElement conveniences used across every UI test suite.
///
/// Every test in this bundle starts from `UITestApp.launch()`, which appends `-uitest` (the
/// launch argument `TMDBSwiftUI/UITestSupport/UITestEnvironment.swift` checks for) plus a pinned
/// English locale, since `MainTabView` tab labels are asserted by their literal text and the app
/// also ships `es-419` localizations.
enum UITestApp {

    @MainActor
    static func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uitest", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        return app
    }
}

extension XCUIElement {

    /// Waits for the element to exist, fails the test if it never does, and returns self so
    /// call sites can chain straight into an interaction: `element.awaitExistence().tap()`.
    @discardableResult
    func awaitExistence(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        XCTAssertTrue(waitForExistence(timeout: timeout), "Expected \(self) to exist within \(timeout)s", file: file, line: line)
        return self
    }

    /// Waits for the element to be hittable (on-screen and not obscured) before tapping — more
    /// reliable than a bare `tap()` right after a navigation transition or scroll.
    func tapWhenHittable(timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Expected \(self) to become hittable within \(timeout)s", file: file, line: line)
        tap()
    }

}

extension XCUIApplication {

    func goToHome() { tabBars.buttons["Home"].tap() }
    func goToMovies() { tabBars.buttons["Movies"].tap() }
    func goToSeries() { tabBars.buttons["Series"].tap() }
    func goToMyStuff() { tabBars.buttons["My Stuff"].tap() }
    func goToSearch() { tabBars.buttons["Search"].tap() }

    /// `SearchView`'s `.searchable(...)` uses the default `.automatic` placement, which on iOS
    /// hides the field under the navigation bar until the content is pulled down — it isn't in
    /// the accessibility tree at all until then. Call this after `goToSearch()` and before
    /// looking up `searchFields`.
    ///
    /// A single `swipeDown()` occasionally doesn't register as the drag distance needed to reveal
    /// the field (a simulator gesture-recognition flake, not app behavior), so this retries a
    /// few times rather than asserting on the first attempt.
    @discardableResult
    func revealSearchField(attempts: Int = 3) -> XCUIElement {
        let field = searchFields.firstMatch
        for _ in 0..<attempts {
            if field.waitForExistence(timeout: 1) { return field }
            swipeDown()
        }
        return field.awaitExistence()
    }

    /// Looks up one of our own `.accessibilityIdentifier(...)` values regardless of which
    /// `XCUIElementType` SwiftUI happens to expose the underlying view as (button, scroll view,
    /// static text, etc.), so tests don't need to track that mapping per view.
    func identified(_ identifier: String) -> XCUIElement {
        descendants(matching: .any)[identifier]
    }

    /// Taps a field and types into it, waiting for the on-screen keyboard to actually appear in
    /// between. A bare `tap()` immediately followed by `typeText(_:)` occasionally races the
    /// focus change (seen as "Neither element nor any descendant has keyboard focus") — the
    /// field's own `hasFocus` attribute never resolves true for this SwiftUI search field, so the
    /// keyboard's appearance is used as the real readiness signal instead.
    func type(_ text: String, into field: XCUIElement, keyboardTimeout: TimeInterval = 5) {
        field.tap()
        _ = keyboards.firstMatch.waitForExistence(timeout: keyboardTimeout)
        field.typeText(text)
    }
}
