import Foundation

public protocol WatchlistServiceProtocol {
    func fetchAccountId(sessionId: String) async throws -> Int
    func fetchMovies(accountId: Int, sessionId: String) async throws -> [WatchlistMovie]
    func fetchTVShows(accountId: Int, sessionId: String) async throws -> [WatchlistTVShow]
}

public final class WatchlistService: WatchlistServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchAccountId(sessionId: String) async throws -> Int {
        let resource = Resource(url: Constants.Urls.account(sessionId: sessionId), modelType: AccountDetailsDTO.self)
        return try await httpClient.load(resource).id
    }

    public func fetchMovies(accountId: Int, sessionId: String) async throws -> [WatchlistMovie] {
        let resource = Resource(url: Constants.Urls.watchlistMovies(accountId: accountId, sessionId: sessionId), modelType: WatchlistResponseDTO<WatchlistMovieDTO>.self)
        return try await httpClient.load(resource).results.map(WatchlistMovie.init)
    }

    public func fetchTVShows(accountId: Int, sessionId: String) async throws -> [WatchlistTVShow] {
        let resource = Resource(url: Constants.Urls.watchlistTVShows(accountId: accountId, sessionId: sessionId), modelType: WatchlistResponseDTO<WatchlistTVShowDTO>.self)
        return try await httpClient.load(resource).results.map(WatchlistTVShow.init)
    }
}
