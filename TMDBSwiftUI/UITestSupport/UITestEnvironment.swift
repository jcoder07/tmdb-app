//
//  UITestEnvironment.swift
//  TMDBSwiftUI
//

#if DEBUG

import Foundation

/// Detects the `-uitest` launch argument and installs every stubbed route the in-scope screens
/// (Home, Movies, Series, Search, and the movie/series/person detail screens they navigate to)
/// need. Account-only screens (Profile, Favorites, Watchlist, My Stuff) are out of scope — the
/// app runs logged out under UI test, so those screens render their empty state without a
/// network call (`sessionManager.getSession() == nil` short-circuits each of their loads).
enum UITestEnvironment {

    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains("-uitest")
    }

    static func installStubs() {
        UITestStubURLProtocol.reset()

        // MARK: Home — HomeViewModel.load() fans out to trending, popular movies (as trailers),
        // discover-by-monetization (streaming/free), on-the-air, now-playing, and lazily loaded
        // per-item videos.
        UITestStubURLProtocol.stub(
            path: "/trending/all/day",
            json: UITestFixtures.multi(movieIds: [1101, 1102], seriesIds: [2201], personIds: [3401])
        )
        UITestStubURLProtocol.stub(
            path: "/trending/all/week",
            json: UITestFixtures.multi(movieIds: [1103], seriesIds: [2202])
        )
        UITestStubURLProtocol.stub(
            path: "/discover/movie",
            matchingQuery: { $0.value(for: "with_watch_monetization_types") == "flatrate" },
            json: UITestFixtures.movieList(ids: UITestFixtures.streamingMovies)
        )
        UITestStubURLProtocol.stub(
            path: "/discover/movie",
            matchingQuery: { $0.value(for: "with_watch_monetization_types") == "free" },
            json: UITestFixtures.movieList(ids: UITestFixtures.freeMovies)
        )
        UITestStubURLProtocol.stub(
            path: "/discover/movie",
            matchingQuery: { $0.value(for: "with_watch_monetization_types") == "rent" },
            json: UITestFixtures.movieList(ids: UITestFixtures.rentMovies)
        )
        UITestStubURLProtocol.stub(
            path: "/discover/tv",
            matchingQuery: { $0.value(for: "with_watch_monetization_types") == "free" },
            json: UITestFixtures.seriesList(ids: UITestFixtures.freeSeries)
        )
        UITestStubURLProtocol.stub(path: "/tv/on_the_air", json: UITestFixtures.seriesList(ids: UITestFixtures.onTheAirSeries))
        UITestStubURLProtocol.stub(path: "/movie/now_playing", json: UITestFixtures.movieList(ids: UITestFixtures.nowPlayingMovies))
        UITestStubURLProtocol.stub(
            matching: { $0.path.hasSuffix("/videos") },
            body: { _ in UITestFixtures.videos }
        )

        // MARK: Movies tab — paginated popular movies.
        UITestStubURLProtocol.stub(
            path: "/movie/popular",
            matchingQuery: { $0.value(for: "page") == "2" },
            json: UITestFixtures.movieList(ids: UITestFixtures.moviesPageTwo, page: 2, totalPages: 2)
        )
        UITestStubURLProtocol.stub(
            path: "/movie/popular",
            json: UITestFixtures.movieList(ids: UITestFixtures.moviesPageOne, page: 1, totalPages: 2)
        )

        // MARK: Series tab
        UITestStubURLProtocol.stub(path: "/tv/popular", json: UITestFixtures.seriesList(ids: UITestFixtures.popularSeries))

        // MARK: Movie / series / person detail — id-derived so any card's id resolves correctly.
        UITestStubURLProtocol.stub(
            matching: { $0.isDetailPath("/movie/") },
            body: { url in UITestFixtures.movieDetail(id: url.trailingID(after: "/movie/")) }
        )
        UITestStubURLProtocol.stub(
            matching: { $0.path.hasSuffix("/credits") && $0.path.contains("/movie/") },
            body: { _ in UITestFixtures.credits }
        )
        UITestStubURLProtocol.stub(
            matching: { $0.path.hasSuffix("/reviews") && $0.path.contains("/movie/") },
            body: { _ in UITestFixtures.reviews }
        )
        UITestStubURLProtocol.stub(
            matching: { $0.isDetailPath("/tv/") },
            body: { url in UITestFixtures.seriesDetail(id: url.trailingID(after: "/tv/")) }
        )
        UITestStubURLProtocol.stub(
            matching: { $0.path.hasSuffix("/credits") && $0.path.contains("/tv/") },
            body: { _ in UITestFixtures.credits }
        )
        UITestStubURLProtocol.stub(
            matching: { $0.path.hasSuffix("/reviews") && $0.path.contains("/tv/") },
            body: { _ in UITestFixtures.reviews }
        )
        UITestStubURLProtocol.stub(
            matching: { $0.isDetailPath("/person/") },
            body: { url in UITestFixtures.personDetail(id: url.trailingID(after: "/person/")) }
        )
        UITestStubURLProtocol.stub(path: "/combined_credits", json: UITestFixtures.combinedCredits)
        UITestStubURLProtocol.stub(path: "/person/popular", json: UITestFixtures.peopleList(ids: UITestFixtures.popularPeople))

        // MARK: Search — genres, multi-search (with and without results), and browse/genre discover.
        UITestStubURLProtocol.stub(path: "/genre/movie/list", json: UITestFixtures.movieGenres)
        UITestStubURLProtocol.stub(
            path: "/search/multi",
            matchingQuery: { $0.value(for: "query") == UITestFixtures.searchQueryWithoutResults },
            json: UITestFixtures.emptyResults
        )
        UITestStubURLProtocol.stub(
            path: "/search/multi",
            json: UITestFixtures.multi(
                movieIds: UITestFixtures.searchMovies,
                seriesIds: UITestFixtures.searchSeries,
                personIds: UITestFixtures.searchPeople
            )
        )
        UITestStubURLProtocol.stub(
            path: "/discover/movie",
            matchingQuery: { $0.value(for: "with_genres") != nil },
            json: UITestFixtures.movieList(ids: UITestFixtures.genreMovies)
        )
        UITestStubURLProtocol.stub(
            path: "/discover/tv",
            matchingQuery: { $0.value(for: "with_genres") != nil },
            json: UITestFixtures.seriesList(ids: UITestFixtures.genreSeries)
        )
    }
}

private extension Array where Element == URLQueryItem {
    func value(for name: String) -> String? {
        first { $0.name == name }?.value
    }
}

private extension URL {
    /// True for a request whose path ends in `/{id}` right after `prefix`, i.e. the resource
    /// endpoint itself rather than one of its sub-resources like `/credits` or `/videos`.
    ///
    /// Requiring the remainder to be all digits (rather than just "no further slash") matters:
    /// `prefix: "/movie/"` would otherwise also match a path like "/genre/movie/list", whose
    /// trailing segment "list" has no further slash but isn't an id.
    func isDetailPath(_ prefix: String) -> Bool {
        guard let range = path.range(of: prefix) else { return false }
        let remainder = path[range.upperBound...]
        return !remainder.isEmpty && remainder.allSatisfy(\.isNumber)
    }

    func trailingID(after prefix: String) -> Int {
        guard let range = path.range(of: prefix) else { return 0 }
        return Int(path[range.upperBound...]) ?? 0
    }
}

#endif
