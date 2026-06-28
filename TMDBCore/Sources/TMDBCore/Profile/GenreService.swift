import Foundation

public protocol GenreServiceProtocol: Sendable {
    func fetchMovieGenres() async throws -> [GenreItem]
    func fetchTVGenres() async throws -> [GenreItem]
}

public final class GenreService: GenreServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchMovieGenres() async throws -> [GenreItem] {
        let resource = Resource(url: Constants.Urls.movieGenres, modelType: GenreListResponseDTO.self)
        return try await httpClient.load(resource).genres.map(GenreItem.init)
    }

    public func fetchTVGenres() async throws -> [GenreItem] {
        let resource = Resource(url: Constants.Urls.tvGenres, modelType: GenreListResponseDTO.self)
        return try await httpClient.load(resource).genres.map(GenreItem.init)
    }
}
