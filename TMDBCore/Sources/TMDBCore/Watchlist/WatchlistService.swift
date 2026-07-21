import Foundation

public protocol WatchlistServiceProtocol: Sendable {
    func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int)
    func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int)
    func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws
    func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws
}

public final class WatchlistService: WatchlistServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
        let resource = Resource(url: Constants.Urls.watchlistMovies(accountId: accountId, sessionId: sessionId, page: page), modelType: WatchlistResponseDTO<WatchlistMovieDTO>.self)
        let response = try await httpClient.load(resource)
        return (response.results.map(WatchlistMovie.init), totalPages: response.totalPages)
    }

    public func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) {
        let resource = Resource(url: Constants.Urls.watchlistTVShows(accountId: accountId, sessionId: sessionId, page: page), modelType: WatchlistResponseDTO<WatchlistTVShowDTO>.self)
        let response = try await httpClient.load(resource)
        return (response.results.map(WatchlistTVShow.init), totalPages: response.totalPages)
    }

    public func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {
        let body = MarkWatchlistRequest(movieId: movieId, inWatchlist: false)
        let resource = try Resource(url: Constants.Urls.markWatchlist(accountId: accountId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }

    public func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {
        let body = MarkWatchlistRequest(seriesId: seriesId, inWatchlist: false)
        let resource = try Resource(url: Constants.Urls.markWatchlist(accountId: accountId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }
}
