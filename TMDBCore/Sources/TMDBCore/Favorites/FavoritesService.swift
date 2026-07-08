import Foundation

public protocol FavoritesServiceProtocol: Sendable {
    func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [FavoriteMovie], totalPages: Int)
    func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [FavoriteTVShow], totalPages: Int)
}

public final class FavoritesService: FavoritesServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [FavoriteMovie], totalPages: Int) {
        let resource = Resource(url: Constants.Urls.favoriteMovies(accountId: accountId, sessionId: sessionId, page: page), modelType: WatchlistResponseDTO<FavoriteMovieDTO>.self)
        let response = try await httpClient.load(resource)
        return (response.results.map(FavoriteMovie.init), totalPages: response.totalPages)
    }

    public func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [FavoriteTVShow], totalPages: Int) {
        let resource = Resource(url: Constants.Urls.favoriteTVShows(accountId: accountId, sessionId: sessionId, page: page), modelType: WatchlistResponseDTO<FavoriteTVShowDTO>.self)
        let response = try await httpClient.load(resource)
        return (response.results.map(FavoriteTVShow.init), totalPages: response.totalPages)
    }
}
