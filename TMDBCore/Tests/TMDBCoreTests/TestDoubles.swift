import Foundation
import Testing
@testable import TMDBCore

// ============================================================
// MARK: - DUMMY Test Doubles
// A Dummy satisfies a type requirement but is never actually
// called. Used when an argument is required by the API but
// is irrelevant to the behavior under test.
// ============================================================

/// Dummy SessionManager – required by initializers but never invoked in the test.
final class DummySessionManager: SessionManagerProtocol, @unchecked Sendable {
    func saveSession(id: String) {}
    func getSession() -> String? { nil }
    func clearSession() {}
    var isLoggedIn: Bool { false }
}

// ============================================================
// MARK: - FAKE Test Doubles
// A Fake has a working implementation, but takes shortcuts
// unsuitable for production (e.g. in-memory instead of Keychain).
// ============================================================

/// Fake SessionManager – stores the session in memory instead of the Keychain.
final class FakeSessionManager: SessionManagerProtocol, @unchecked Sendable {
    private var storedId: String?

    func saveSession(id: String) { storedId = id }
    func getSession() -> String? { storedId }
    func clearSession() { storedId = nil }
    var isLoggedIn: Bool { storedId != nil }
}

/// Fake WatchlistService – stores items in memory with real remove semantics.
final class FakeWatchlistService: WatchlistServiceProtocol, @unchecked Sendable {
    var movies: [WatchlistMovie] = []
    var tvShows: [WatchlistTVShow] = []
    var totalMoviePages = 1
    var totalTVPages = 1

    func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
        (items: movies, totalPages: totalMoviePages)
    }

    func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) {
        (items: tvShows, totalPages: totalTVPages)
    }

    func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {
        movies.removeAll { $0.id == movieId }
    }

    func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {
        tvShows.removeAll { $0.id == seriesId }
    }
}

// ============================================================
// MARK: - STUB Test Doubles
// A Stub returns pre-programmed answers to calls during tests.
// Stubs do NOT record call history.
// ============================================================

/// Stub HttpClient – returns a pre-configured response for any resource.
final class StubHttpClient: HttpClientProtocol, @unchecked Sendable {
    private var responses: [Any]
    private var index = 0
    var errorToThrow: Error?

    init(_ responses: Any...) {
        self.responses = responses
    }

    func load<T: Decodable>(_ resource: Resource<T>) async throws -> T {
        if let error = errorToThrow { throw error }
        guard index < responses.count, let result = responses[index] as? T else {
            throw NetworkError.decodingError
        }
        index += 1
        return result
    }
}

/// Stub MoviesService – always returns a fixed page.
final class StubMoviesService: MoviesServiceProtocol, @unchecked Sendable {
    var pageToReturn: MoviesPage
    var errorToThrow: Error?

    init(movies: [Movie] = [], totalPages: Int = 1) {
        pageToReturn = MoviesPage(movies: movies, page: 1, totalPages: totalPages)
    }

    func fetchPopularMovies(page: Int) async throws -> MoviesPage {
        if let error = errorToThrow { throw error }
        return pageToReturn
    }
}

/// Stub HomeService – returns pre-configured section data.
final class StubHomeService: HomeServiceProtocol, @unchecked Sendable {
    var trendingResults: [SearchResult] = []
    var popularMovies: [Movie] = []
    var discoverMovies: [Movie] = []
    var discoverTV: [Series] = []
    var nowPlayingMovies: [Movie] = []
    var onTheAirSeries: [Series] = []
    var movieVideos: [Video] = []
    var tvVideos: [Video] = []
    var errorToThrow: Error?

    func fetchTrending(timeWindow: String, page: Int) async throws -> [SearchResult] {
        if let error = errorToThrow { throw error }
        return trendingResults
    }
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        if let error = errorToThrow { throw error }
        return popularMovies
    }
    func fetchNowPlaying(page: Int) async throws -> [Movie] {
        if let error = errorToThrow { throw error }
        return nowPlayingMovies
    }
    func fetchOnTheAir(page: Int) async throws -> [Series] {
        if let error = errorToThrow { throw error }
        return onTheAirSeries
    }
    func fetchDiscoverMovies(monetizationType: String, page: Int) async throws -> [Movie] {
        if let error = errorToThrow { throw error }
        return discoverMovies
    }
    func fetchDiscoverTV(monetizationType: String, page: Int) async throws -> [Series] {
        if let error = errorToThrow { throw error }
        return discoverTV
    }
    func fetchMovieVideos(movieId: Int) async throws -> [Video] {
        if let error = errorToThrow { throw error }
        return movieVideos
    }
    func fetchTVVideos(seriesId: Int) async throws -> [Video] {
        if let error = errorToThrow { throw error }
        return tvVideos
    }
}

/// Stub SearchService – returns preset results.
final class StubSearchService: SearchServiceProtocol, @unchecked Sendable {
    var results: [SearchResult] = []
    var genreMovies: [Movie] = []
    var genreSeries: [Series] = []
    var errorToThrow: Error?

    func searchMulti(query: String, page: Int) async throws -> [SearchResult] {
        if let error = errorToThrow { throw error }
        return results
    }
    func discoverByGenre(genreId: Int, page: Int) async throws -> (movies: [Movie], series: [Series]) {
        if let error = errorToThrow { throw error }
        return (movies: genreMovies, series: genreSeries)
    }
}

/// Stub GenreService – returns preset genres.
final class StubGenreService: GenreServiceProtocol, @unchecked Sendable {
    var movieGenres: [GenreItem] = []
    var tvGenres: [GenreItem] = []
    var errorToThrow: Error?

    func fetchMovieGenres() async throws -> [GenreItem] {
        if let error = errorToThrow { throw error }
        return movieGenres
    }
    func fetchTVGenres() async throws -> [GenreItem] {
        if let error = errorToThrow { throw error }
        return tvGenres
    }
}

/// Stub AuthService – returns preset token and session.
final class StubAuthService: TMDBAuthServiceProtocol, @unchecked Sendable {
    var tokenToReturn = RequestTokenResponse(success: true, expiresAt: nil, requestToken: "stub-token")
    var sessionToReturn = CreateSessionResponse(success: true, sessionId: "stub-session")
    var errorToThrow: Error?

    func createRequestToken() async throws -> RequestTokenResponse {
        if let error = errorToThrow { throw error }
        return tokenToReturn
    }
    func validateLogin(username: String, password: String, requestToken: String) async throws {
        if let error = errorToThrow { throw error }
    }
    func createSession(requestToken: String) async throws -> CreateSessionResponse {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }
}

/// Stub AccountService – returns a preset profile and rated content.
final class StubAccountService: AccountServiceProtocol, @unchecked Sendable {
    var profileToReturn = AccountProfile(id: 99, displayName: "Test User", avatarURL: nil)
    var ratedMovies: [RatedMovie] = []
    var ratedTV: [RatedTVShow] = []
    var errorToThrow: Error?

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        if let error = errorToThrow { throw error }
        return profileToReturn
    }
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        if let error = errorToThrow { throw error }
        return ratedMovies
    }
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        if let error = errorToThrow { throw error }
        return ratedTV
    }
}

// ============================================================
// MARK: - SPY Test Doubles
// A Spy is a Stub that also records how it was called so tests
// can assert on interaction details after the fact.
// ============================================================

/// Spy HttpClient – records every resource URL and HTTP method loaded.
/// Used as the basis for all service-layer tests.
final class MockHttpClient: HttpClientProtocol, @unchecked Sendable {
    var stubbedResponses: [Any] = []
    var errorToThrow: Error?
    private(set) var capturedURLs: [URL] = []
    private(set) var capturedMethods: [String] = []
    private var callCount = 0

    func load<T: Decodable>(_ resource: Resource<T>) async throws -> T {
        capturedURLs.append(resource.url)
        capturedMethods.append(resource.method.name)
        if let error = errorToThrow { throw error }
        guard callCount < stubbedResponses.count else { throw NetworkError.decodingError }
        let response = stubbedResponses[callCount]
        callCount += 1
        guard let result = response as? T else { throw NetworkError.decodingError }
        return result
    }
}

/// Spy SessionManager – records every call and its arguments.
final class SpySessionManager: SessionManagerProtocol, @unchecked Sendable {
    private(set) var savedIds: [String] = []
    private(set) var getSessionCallCount = 0
    private(set) var clearSessionCallCount = 0
    private var storedId: String?

    // Pre-seed a session without recording a save call
    func seedSession(id: String) { storedId = id }

    func saveSession(id: String) { savedIds.append(id); storedId = id }
    func getSession() -> String? { getSessionCallCount += 1; return storedId }
    func clearSession() { clearSessionCallCount += 1; storedId = nil }
    var isLoggedIn: Bool { storedId != nil }
}

/// Spy AuthService – records every call with its arguments.
final class SpyAuthService: TMDBAuthServiceProtocol, @unchecked Sendable {
    private(set) var createTokenCallCount = 0
    private(set) var validateLoginCalls: [(username: String, password: String, token: String)] = []
    private(set) var createSessionCalls: [String] = []

    var tokenToReturn = RequestTokenResponse(success: true, expiresAt: nil, requestToken: "spy-token")
    var sessionToReturn = CreateSessionResponse(success: true, sessionId: "spy-session")
    var tokenErrorToThrow: Error?
    var validateErrorToThrow: Error?
    var sessionErrorToThrow: Error?

    func createRequestToken() async throws -> RequestTokenResponse {
        createTokenCallCount += 1
        if let error = tokenErrorToThrow { throw error }
        return tokenToReturn
    }
    func validateLogin(username: String, password: String, requestToken: String) async throws {
        validateLoginCalls.append((username: username, password: password, token: requestToken))
        if let error = validateErrorToThrow { throw error }
    }
    func createSession(requestToken: String) async throws -> CreateSessionResponse {
        createSessionCalls.append(requestToken)
        if let error = sessionErrorToThrow { throw error }
        return sessionToReturn
    }
}

/// Spy MoviesService – records which pages were requested.
final class SpyMoviesService: MoviesServiceProtocol, @unchecked Sendable {
    private(set) var fetchedPages: [Int] = []
    var pageToReturn = MoviesPage(movies: [], page: 1, totalPages: 1)
    var errorToThrow: Error?

    func fetchPopularMovies(page: Int) async throws -> MoviesPage {
        fetchedPages.append(page)
        if let error = errorToThrow { throw error }
        return pageToReturn
    }
}

/// Spy MovieDetailService – records all method calls with their arguments.
final class SpyMovieDetailService: MovieDetailServiceProtocol, @unchecked Sendable {
    private(set) var fetchDetailCalls: [Int] = []
    private(set) var fetchCreditsCalls: [Int] = []
    private(set) var fetchReviewsCalls: [Int] = []
    private(set) var markFavoriteCalls: [(accountId: Int, movieId: Int, isFavorite: Bool)] = []
    private(set) var markWatchlistCalls: [(accountId: Int, movieId: Int, inWatchlist: Bool)] = []
    private(set) var addToListCalls: [(listId: Int, movieId: Int)] = []

    var detailToReturn = MovieDetail(
        id: 1, title: "Test Movie", overview: "Overview",
        backdropURL: nil, posterURL: nil, releaseDate: "2024-01-01",
        voteAverage: 7.5, voteCount: 100, runtime: 120,
        genres: [], tagline: nil, status: "Released",
        budget: nil, revenue: nil
    )
    var creditsToReturn: [CastMember] = []
    var reviewsToReturn: [Review] = []
    var accountStatesToReturn: (isFavorite: Bool, isInWatchlist: Bool) = (false, false)
    var userListsToReturn: [UserList] = []
    var errorToThrow: Error?
    var markErrorToThrow: Error?

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        fetchDetailCalls.append(id)
        if let error = errorToThrow { throw error }
        return detailToReturn
    }
    func fetchCredits(id: Int) async throws -> [CastMember] {
        fetchCreditsCalls.append(id)
        if let error = errorToThrow { throw error }
        return creditsToReturn
    }
    func fetchReviews(id: Int) async throws -> [Review] {
        fetchReviewsCalls.append(id)
        if let error = errorToThrow { throw error }
        return reviewsToReturn
    }
    func fetchAccountStates(movieId: Int, sessionId: String) async throws -> (isFavorite: Bool, isInWatchlist: Bool) {
        if let error = errorToThrow { throw error }
        return accountStatesToReturn
    }
    func markFavorite(accountId: Int, movieId: Int, sessionId: String, isFavorite: Bool) async throws {
        markFavoriteCalls.append((accountId: accountId, movieId: movieId, isFavorite: isFavorite))
        if let error = markErrorToThrow { throw error }
    }
    func markWatchlist(accountId: Int, movieId: Int, sessionId: String, inWatchlist: Bool) async throws {
        markWatchlistCalls.append((accountId: accountId, movieId: movieId, inWatchlist: inWatchlist))
        if let error = markErrorToThrow { throw error }
    }
    func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList] {
        if let error = errorToThrow { throw error }
        return userListsToReturn
    }
    func addMovieToList(listId: Int, movieId: Int, sessionId: String) async throws {
        addToListCalls.append((listId: listId, movieId: movieId))
        if let error = errorToThrow { throw error }
    }
}

// ============================================================
// MARK: - MOCK Test Doubles
// A Mock has pre-programmed expectations and verifies that the
// system under test makes the right calls. Call verify() at the
// end of the test to assert the expectations were met.
// ============================================================

/// Mock AccountService – verifies expected call counts at end of test.
final class MockAccountService: AccountServiceProtocol, @unchecked Sendable {
    var expectedFetchDetailsCount: Int?
    var expectedRatedMoviesCount: Int?
    var expectedRatedTVCount: Int?

    private(set) var fetchDetailsCallCount = 0
    private(set) var ratedMoviesCallCount = 0
    private(set) var ratedTVCallCount = 0

    var profileToReturn = AccountProfile(id: 42, displayName: "Mock User", avatarURL: nil)
    var ratedMoviesToReturn: [RatedMovie] = []
    var ratedTVToReturn: [RatedTVShow] = []
    var errorToThrow: Error?

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        fetchDetailsCallCount += 1
        if let error = errorToThrow { throw error }
        return profileToReturn
    }
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        ratedMoviesCallCount += 1
        if let error = errorToThrow { throw error }
        return ratedMoviesToReturn
    }
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        ratedTVCallCount += 1
        if let error = errorToThrow { throw error }
        return ratedTVToReturn
    }

    /// Asserts that all pre-programmed call-count expectations were met.
    func verify(sourceLocation: SourceLocation = #_sourceLocation) {
        if let expected = expectedFetchDetailsCount {
            #expect(fetchDetailsCallCount == expected, sourceLocation: sourceLocation)
        }
        if let expected = expectedRatedMoviesCount {
            #expect(ratedMoviesCallCount == expected, sourceLocation: sourceLocation)
        }
        if let expected = expectedRatedTVCount {
            #expect(ratedTVCallCount == expected, sourceLocation: sourceLocation)
        }
    }
}

/// Mock WatchlistService – verifies that specific remove calls occurred in the right order.
final class MockWatchlistService: WatchlistServiceProtocol, @unchecked Sendable {
    var expectedRemovedMovieIds: [Int] = []
    var expectedRemovedTVIds: [Int] = []

    private(set) var removedMovieIds: [Int] = []
    private(set) var removedTVIds: [Int] = []

    var moviesToReturn: [WatchlistMovie] = []
    var tvShowsToReturn: [WatchlistTVShow] = []
    var totalMoviePages = 1
    var totalTVPages = 1
    var removeMovieErrorToThrow: Error?
    var removeTVErrorToThrow: Error?

    func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
        (items: moviesToReturn, totalPages: totalMoviePages)
    }
    func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) {
        (items: tvShowsToReturn, totalPages: totalTVPages)
    }
    func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {
        if let error = removeMovieErrorToThrow { throw error }
        removedMovieIds.append(movieId)
    }
    func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {
        if let error = removeTVErrorToThrow { throw error }
        removedTVIds.append(seriesId)
    }

    /// Asserts that the expected remove calls were made.
    func verify(sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(removedMovieIds == expectedRemovedMovieIds, sourceLocation: sourceLocation)
        #expect(removedTVIds == expectedRemovedTVIds, sourceLocation: sourceLocation)
    }
}

// ============================================================
// MARK: - Shared factory helpers
// ============================================================

func makeMovie(id: Int, title: String? = nil) -> Movie {
    Movie(id: id, title: title ?? "Movie \(id)", posterURL: nil, voteAverage: 7.0, releaseDate: "2024-01-01")
}

func makeSeries(id: Int, name: String? = nil) -> Series {
    Series(id: id, name: name ?? "Series \(id)", posterURL: nil, voteAverage: 7.5, firstAirDate: "2024-01-01")
}

func makeWatchlistMovie(id: Int, title: String? = nil) -> WatchlistMovie {
    WatchlistMovie(id: id, title: title ?? "Movie \(id)", overview: "Overview", posterURL: nil, voteAverage: 7.0, releaseDate: nil)
}

func makeWatchlistTVShow(id: Int, name: String? = nil) -> WatchlistTVShow {
    WatchlistTVShow(id: id, name: name ?? "Show \(id)", overview: "Overview", posterURL: nil, voteAverage: 7.5, firstAirDate: nil)
}

func makeCastMember(id: Int) -> CastMember {
    CastMember(id: id, name: "Actor \(id)", character: "Character \(id)", profileURL: nil, order: id)
}

func makeReview(id: String) -> Review {
    Review(id: id, author: "Reviewer", content: "Great movie!", createdAt: nil, rating: 8.0)
}
