//
//  SearchUITests.swift
//  TMDBSwiftUIUITests
//

import XCTest

/// Covers the Search tab's idle Discover/Categories state, typed-query suggestions and their
/// detail navigation, the empty-results state, and the Discover/Category browse destinations.
final class SearchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testIdleStateShowsDiscoverCardsAndCategories() {
        let app = UITestApp.launch()
        app.goToSearch()

        app.identified("search.discover.movies").awaitExistence()
        app.identified("search.discover.tv").awaitExistence()
        app.identified("search.discover.people").awaitExistence()

        // Categories are populated from the `/genre/movie/list` fixture (Action = genre id 28).
        // The category's label text is merged into its parent button's accessibility element by
        // VoiceOver, so it isn't independently queryable by label — assert via the button's id.
        app.identified("search.category.28").awaitExistence()
    }

    @MainActor
    func testTypingAQueryShowsSuggestions() {
        let app = UITestApp.launch()
        app.goToSearch()
        typeQuery(UITestCatalog.searchQueryWithResults, into: app)

        // `SearchViewModel.search()` debounces for 300ms before firing — wait rather than sleep.
        app.identified("search.suggestion.movie-\(UITestCatalog.searchMovieID)").awaitExistence(timeout: 5)
    }

    @MainActor
    func testTappingAMovieSuggestionPushesMovieDetail() {
        let app = UITestApp.launch()
        app.goToSearch()
        typeQuery(UITestCatalog.searchQueryWithResults, into: app)

        app.identified("search.suggestion.movie-\(UITestCatalog.searchMovieID)").awaitExistence().tap()

        let title = app.identified("movieDetail.title").awaitExistence()
        XCTAssertEqual(title.label, UITestCatalog.movieTitle(UITestCatalog.searchMovieID))
    }

    @MainActor
    func testTappingASeriesSuggestionPushesSeriesDetail() {
        let app = UITestApp.launch()
        app.goToSearch()
        typeQuery(UITestCatalog.searchQueryWithResults, into: app)

        app.identified("search.suggestion.series-\(UITestCatalog.searchSeriesID)").awaitExistence().tap()

        let title = app.identified("seriesDetail.title").awaitExistence()
        XCTAssertEqual(title.label, UITestCatalog.seriesTitle(UITestCatalog.searchSeriesID))
    }

    @MainActor
    func testTappingAPersonSuggestionPushesPersonDetail() {
        let app = UITestApp.launch()
        app.goToSearch()
        typeQuery(UITestCatalog.searchQueryWithResults, into: app)

        app.identified("search.suggestion.person-\(UITestCatalog.searchPersonID)").awaitExistence().tap()

        let name = app.identified("personDetail.name").awaitExistence()
        XCTAssertEqual(name.label, UITestCatalog.personName(UITestCatalog.searchPersonID))
    }

    @MainActor
    func testAQueryWithNoMatchesShowsTheEmptyState() {
        let app = UITestApp.launch()
        app.goToSearch()
        typeQuery(UITestCatalog.searchQueryWithoutResults, into: app)

        app.identified("search.emptyResults").awaitExistence()
        app.staticTexts["No results for \"\(UITestCatalog.searchQueryWithoutResults)\""].awaitExistence()
    }

    @MainActor
    func testDiscoverMoviesCardPushesBrowseResults() {
        let app = UITestApp.launch()
        app.goToSearch()

        app.identified("search.discover.movies").awaitExistence().tap()
        app.identified("browseResults.root").awaitExistence()
    }

    @MainActor
    func testCategoryCardPushesGenreResults() {
        let app = UITestApp.launch()
        app.goToSearch()

        app.identified("search.category.28").awaitExistence().tap()
        app.identified("genreResults.root").awaitExistence()
    }

    @MainActor
    private func typeQuery(_ query: String, into app: XCUIApplication) {
        let searchField = app.revealSearchField()
        app.type(query, into: searchField)
    }
}
