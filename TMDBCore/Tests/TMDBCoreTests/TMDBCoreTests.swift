import Testing
import Foundation
@testable import TMDBCore

// MARK: - Helpers

private struct MockHTTPSuccess: HttpClientProtocol {
    let moviesJSON: String
    let tvShowsJSON: String

    func load<T: Decodable>(_ resource: Resource<T>) async throws -> T {
        let json: String
        if resource.url.absoluteString.contains("watchlist/movies") {
            json = moviesJSON
        } else if resource.url.absoluteString.contains("watchlist/tv") {
            json = tvShowsJSON
        } else if resource.url.absoluteString.contains("/account?") {
            json = #"{"id": 123}"#
        } else {
            throw NetworkError.invalidResponse
        }
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}

private struct MockHTTPFailure: HttpClientProtocol {
    func load<T: Decodable>(_ resource: Resource<T>) async throws -> T {
        throw URLError(.notConnectedToInternet)
    }
}

private struct MockAccountServiceSuccess: AccountServiceProtocol {
    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        AccountProfile(id: 42, displayName: "test", avatarURL: nil)
    }
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] { [] }
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] { [] }
}

private struct MockSession: SessionManagerProtocol {
    func saveSession(id: String) {}
    func getSession() -> String? { "test_session" }
    func clearSession() {}
    var isLoggedIn: Bool { true }
}

private struct MockSessionNil: SessionManagerProtocol {
    func saveSession(id: String) {}
    func getSession() -> String? { nil }
    func clearSession() {}
    var isLoggedIn: Bool { false }
}

// MARK: - WatchlistService Tests

@Test func watchlistServiceMapsMoviesCorrectly() async throws {
    let moviesJSON = #"""
    {
        "page": 1,
        "results": [
            {"id": 1, "title": "Inception", "overview": "A dream heist.", "poster_path": "/x", "vote_average": 8.4, "release_date": "2010-07-16"},
            {"id": 2, "title": "The Dark Knight", "overview": "Batman.", "poster_path": "/y", "vote_average": 9.0, "release_date": "2008-07-18"}
        ],
        "total_pages": 5
    }
    """#
    let tvJSON = #"{"page": 1, "results": [], "total_pages": 1}"#
    let client = MockHTTPSuccess(moviesJSON: moviesJSON, tvShowsJSON: tvJSON)
    let service = WatchlistService(httpClient: client)
    let result = try await service.fetchMovies(accountId: 1, sessionId: "s", page: 1)
    #expect(result.items.count == 2)
    #expect(result.items[0].title == "Inception")
    #expect(result.items[1].voteAverage == 9.0)
    #expect(result.totalPages == 5)
}

@Test func watchlistServiceMapsTVShowsCorrectly() async throws {
    let moviesJSON = #"{"page": 1, "results": [], "total_pages": 1}"#
    let tvJSON = #"""
    {
        "page": 1,
        "results": [
            {"id": 10, "name": "Breaking Bad", "overview": "Chemistry.", "poster_path": "/z", "vote_average": 9.5, "first_air_date": "2008-01-20"}
        ],
        "total_pages": 3
    }
    """#
    let client = MockHTTPSuccess(moviesJSON: moviesJSON, tvShowsJSON: tvJSON)
    let service = WatchlistService(httpClient: client)
    let result = try await service.fetchTVShows(accountId: 1, sessionId: "s", page: 1)
    #expect(result.items.count == 1)
    #expect(result.items[0].name == "Breaking Bad")
    #expect(result.totalPages == 3)
}

@Test func watchlistServiceIncludesPageInURL() async throws {
    let moviesJSON = #"{"page": 2, "results": [], "total_pages": 5}"#
    let tvJSON = #"{"page": 1, "results": [], "total_pages": 1}"#
    let client = MockHTTPSuccess(moviesJSON: moviesJSON, tvShowsJSON: tvJSON)
    let service = WatchlistService(httpClient: client)
    let result = try await service.fetchMovies(accountId: 1, sessionId: "s", page: 2)
    #expect(result.totalPages == 5)
}

// MARK: - WatchlistViewModel Tests

@MainActor
@Test func viewModelLoadsMoviesAndTVShows() async throws {
    let moviesJSON = #"""
    {
        "page": 1,
        "results": [
            {"id": 1, "title": "Inception", "overview": "A dream heist.", "poster_path": "/x", "vote_average": 8.4, "release_date": "2010-07-16"}
        ],
        "total_pages": 3
    }
    """#
    let tvJSON = #"""
    {
        "page": 1,
        "results": [
            {"id": 10, "name": "Breaking Bad", "overview": "Chemistry.", "poster_path": "/z", "vote_average": 9.5, "first_air_date": "2008-01-20"}
        ],
        "total_pages": 2
    }
    """#
    let client = MockHTTPSuccess(moviesJSON: moviesJSON, tvShowsJSON: tvJSON)
    let service = WatchlistService(httpClient: client)
    let vm = WatchlistViewModel(service: service, accountService: MockAccountServiceSuccess(), sessionManager: MockSession())
    #expect(vm.movies.isEmpty)
    #expect(vm.tvShows.isEmpty)
    await vm.load()
    #expect(vm.movies.count == 1)
    #expect(vm.movies[0].title == "Inception")
    #expect(vm.tvShows.count == 1)
    #expect(vm.tvShows[0].name == "Breaking Bad")
    #expect(vm.canLoadMoreMovies == true)
    #expect(vm.canLoadMoreTVShows == true)
    #expect(vm.errorMessage == nil)
    #expect(vm.isLoading == false)
}

@MainActor
@Test func viewModelLoadReturnsEarlyWhenNoSession() async throws {
    let client = MockHTTPFailure()
    let service = WatchlistService(httpClient: client)
    let vm = WatchlistViewModel(service: service, accountService: MockAccountServiceSuccess(), sessionManager: MockSessionNil())
    await vm.load()
    #expect(vm.movies.isEmpty)
    #expect(vm.tvShows.isEmpty)
    #expect(vm.errorMessage == nil)
    #expect(vm.isLoading == false)
}

@MainActor
@Test func viewModelSetsErrorMessageWhenServiceFails() async throws {
    let client = MockHTTPFailure()
    let service = WatchlistService(httpClient: client)
    let vm = WatchlistViewModel(service: service, accountService: MockAccountServiceSuccess(), sessionManager: MockSession())
    await vm.load()
    #expect(vm.movies.isEmpty)
    #expect(vm.tvShows.isEmpty)
    #expect(vm.errorMessage != nil)
}

@MainActor
@Test func viewModelCachesAccountId() async throws {
    let moviesJSON = #"{"page": 1, "results": [], "total_pages": 1}"#
    let tvJSON = #"{"page": 1, "results": [], "total_pages": 1}"#
    let client = MockHTTPSuccess(moviesJSON: moviesJSON, tvShowsJSON: tvJSON)
    let service = WatchlistService(httpClient: client)
    var callCount = 0
    let accountService = MockAccountServiceWithTracker(onFetch: { callCount += 1 })
    let vm = WatchlistViewModel(service: service, accountService: accountService, sessionManager: MockSession())
    await vm.load()
    #expect(callCount == 1)
    await vm.load()
    #expect(callCount == 1)
}

private struct MockAccountServiceWithTracker: AccountServiceProtocol {
    let onFetch: () -> Void
    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        onFetch()
        return AccountProfile(id: 42, displayName: "test", avatarURL: nil)
    }
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] { [] }
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] { [] }
}

@MainActor
@Test func viewModelReentryGuardSkipsDuplicateLoad() async throws {
    let moviesJSON = #"""
    {
        "page": 1,
        "results": [
            {"id": 1, "title": "Inception", "overview": "Dream.", "poster_path": "/x", "vote_average": 8.4, "release_date": "2010-07-16"}
        ],
        "total_pages": 1
    }
    """#
    let tvJSON = #"{"page": 1, "results": [], "total_pages": 1}"#
    let client = MockHTTPSuccess(moviesJSON: moviesJSON, tvShowsJSON: tvJSON)
    let service = WatchlistService(httpClient: client)
    let vm = WatchlistViewModel(service: service, accountService: MockAccountServiceSuccess(), sessionManager: MockSession())
    async let first = vm.load()
    async let second = vm.load()
    _ = await (first, second)
    #expect(vm.movies.count == 1)
}

@MainActor
@Test func viewModelLoadMoreAppendsPage() async throws {
    let page1JSON = #"""
    {
        "page": 1,
        "results": [
            {"id": 1, "title": "Inception", "overview": "Dream.", "poster_path": "/x", "vote_average": 8.4, "release_date": "2010-07-16"}
        ],
        "total_pages": 2
    }
    """#
    let page2JSON = #"""
    {
        "page": 2,
        "results": [
            {"id": 2, "title": "The Dark Knight", "overview": "Batman.", "poster_path": "/y", "vote_average": 9.0, "release_date": "2008-07-18"}
        ],
        "total_pages": 2
    }
    """#
    let tvJSON = #"{"page": 1, "results": [], "total_pages": 1}"#

    let service = MockPaginatedService(page1Movies: page1JSON, page2Movies: page2JSON, tvJSON: tvJSON)
    let vm = WatchlistViewModel(service: service, accountService: MockAccountServiceSuccess(), sessionManager: MockSession())
    await vm.load()
    #expect(vm.movies.count == 1)
    #expect(vm.canLoadMoreMovies == true)

    vm.selectedTab = .movies
    await vm.loadMore()
    #expect(vm.movies.count == 2)
    #expect(vm.movies[1].title == "The Dark Knight")
}

private struct MockPaginatedService: WatchlistServiceProtocol {
    let page1Movies: String
    let page2Movies: String
    let tvJSON: String
    var callCount = 0

    func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
        let json = page == 1 ? page1Movies : page2Movies
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(WatchlistResponseDTO<WatchlistMovieDTO>.self, from: data)
        return (dto.results.map(WatchlistMovie.init), totalPages: dto.totalPages)
    }

    func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) {
        let data = tvJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(WatchlistResponseDTO<WatchlistTVShowDTO>.self, from: data)
        return (dto.results.map(WatchlistTVShow.init), totalPages: dto.totalPages)
    }
}
