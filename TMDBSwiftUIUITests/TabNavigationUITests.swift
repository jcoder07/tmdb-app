//
//  TabNavigationUITests.swift
//  TMDBSwiftUIUITests
//

import XCTest

/// Covers tab bar navigation, the Home toolbar chrome, and the four Home sections rendering
/// from stubbed fixtures. The app runs logged out under `-uitest`, so account-only screens
/// (Profile, Watchlist, Favorites, My Stuff lists) are out of scope for this bundle.
final class TabNavigationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAllTabsNavigateToTheirOwnScreen() {
        let app = UITestApp.launch()

        app.navigationBars["Home"].awaitExistence()

        app.goToMovies()
        app.navigationBars["Movies"].awaitExistence()

        app.goToSeries()
        app.navigationBars["Series"].awaitExistence()

        app.goToMyStuff()
        app.navigationBars["My Stuff"].awaitExistence()

        app.goToSearch()
        app.navigationBars["Search"].awaitExistence()

        app.goToHome()
        app.navigationBars["Home"].awaitExistence()
    }

    @MainActor
    func testSwitchingAwayFromMoviesAndBackPreservesTheGrid() {
        let app = UITestApp.launch()

        app.goToMovies()
        app.identified("movies.grid").awaitExistence()
        let firstCard = app.identified("movies.card.\(UITestCatalog.moviesPageOne[0])").awaitExistence()
        XCTAssertTrue(firstCard.exists)

        app.goToSeries()
        app.navigationBars["Series"].awaitExistence()

        app.goToMovies()
        // The grid should still be populated immediately — no loading spinner, no re-fetch.
        app.identified("movies.card.\(UITestCatalog.moviesPageOne[0])").awaitExistence()
    }

    @MainActor
    func testHomeThemeToggleFlipsBetweenLightAndDarkIcon() {
        let app = UITestApp.launch()
        let toggle = app.identified("home.themeToggle").awaitExistence()

        // The toolbar button collapses its `Image(systemName:)` into its own accessibility
        // element rather than exposing a separate Image descendant, so the SF Symbol's name
        // is only readable via the button's own accessibility label/value.
        let before = toggle.label
        toggle.tap()
        let after = app.identified("home.themeToggle").awaitExistence().label
        XCTAssertNotEqual(before, after)
    }

    @MainActor
    func testHomeRendersAllFourSectionsWithFixtureContent() {
        let app = UITestApp.launch()

        app.staticTexts["Trending"].awaitExistence()
        app.staticTexts["Latest Trailers"].awaitExistence()
        app.staticTexts["What's Popular"].awaitExistence()
        app.staticTexts["Free To Watch"].awaitExistence()

        app.identified("home.rail.trending").awaitExistence()
        app.identified("home.rail.trailers").awaitExistence()
        app.identified("home.rail.popular").awaitExistence()
        app.identified("home.rail.free").awaitExistence()

        app.identified("home.rail.trending.card.movie-\(UITestCatalog.trendingMovieID)").awaitExistence()
    }
}
