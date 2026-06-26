import Foundation

public protocol ProfileServiceProtocol {
    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie]
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow]
    func fetchMovieGenres() async throws -> [GenreItem]
    func fetchTVGenres() async throws -> [GenreItem]
}

public final class ProfileService: ProfileServiceProtocol {

    private let accountService: AccountServiceProtocol
    private let genreService: GenreServiceProtocol

    public init(accountService: AccountServiceProtocol, genreService: GenreServiceProtocol) {
        self.accountService = accountService
        self.genreService = genreService
    }

    public func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        try await accountService.fetchAccountDetails(sessionId: sessionId)
    }

    public func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        try await accountService.fetchRatedMovies(accountId: accountId, sessionId: sessionId)
    }

    public func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        try await accountService.fetchRatedTVShows(accountId: accountId, sessionId: sessionId)
    }

    public func fetchMovieGenres() async throws -> [GenreItem] {
        try await genreService.fetchMovieGenres()
    }

    public func fetchTVGenres() async throws -> [GenreItem] {
        try await genreService.fetchTVGenres()
    }
}
