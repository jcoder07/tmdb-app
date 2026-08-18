//
//  BrowseDetailUITests.swift
//  TMDBSwiftUIUITests
//

import XCTest

/// Covers Movies grid → detail, Series list → detail, Home rail → detail, and Movies pagination.
final class BrowseDetailUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTappingAMovieCardPushesItsDetailScreen() {
        let app = UITestApp.launch()
        app.goToMovies()

        let id = UITestCatalog.moviesPageOne[0]
        app.identified("movies.card.\(id)").awaitExistence().tap()

        let title = app.identified("movieDetail.title").awaitExistence()
        XCTAssertEqual(title.label, UITestCatalog.movieTitle(id))
    }

    @MainActor
    func testMovieDetailBackButtonReturnsToTheGrid() {
        let app = UITestApp.launch()
        app.goToMovies()

        let id = UITestCatalog.moviesPageOne[0]
        app.identified("movies.card.\(id)").awaitExistence().tap()
        app.identified("movieDetail.title").awaitExistence()

        app.identified("movieDetail.back").awaitExistence().tap()

        app.identified("movies.grid").awaitExistence()
        app.identified("movies.card.\(id)").awaitExistence()
    }

    @MainActor
    func testTappingASeriesCardPushesItsDetailScreen() {
        let app = UITestApp.launch()
        app.goToSeries()

        let id = UITestCatalog.popularSeries[0]
        app.identified("series.card.\(id)").awaitExistence().tap()

        let title = app.identified("seriesDetail.title").awaitExistence()
        XCTAssertEqual(title.label, UITestCatalog.seriesTitle(id))
    }

    @MainActor
    func testHomeTrendingRailCardPushesMovieDetail() {
        let app = UITestApp.launch()

        let id = UITestCatalog.trendingMovieID
        app.identified("home.rail.trending.card.movie-\(id)").awaitExistence().tap()

        let title = app.identified("movieDetail.title").awaitExistence()
        XCTAssertEqual(title.label, UITestCatalog.movieTitle(id))
    }

    @MainActor
    func testScrollingToTheLastMovieLoadsTheNextPage() {
        let app = UITestApp.launch()
        app.goToMovies()

        let grid = app.identified("movies.grid").awaitExistence()
        let lastFirstPageID = UITestCatalog.moviesPageOne.last!
        app.identified("movies.card.\(lastFirstPageID)").awaitExistence()

        // Scrolling to the last item of page one triggers `MoviesViewModel.loadNextPage()`.
        grid.swipeUp()

        let nextPageID = UITestCatalog.moviesPageTwo[0]
        app.identified("movies.card.\(nextPageID)").awaitExistence(timeout: 10)
    }
}
