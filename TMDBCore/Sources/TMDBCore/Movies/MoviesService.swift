import Foundation

public protocol MoviesServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> MoviesPage
}

public final class MoviesService: MoviesServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchPopularMovies(page: Int) async throws -> MoviesPage {
        let resource = Resource(url: Constants.Urls.popularMovies(page: page), modelType: PopularMoviesResponseDTO.self)
        return MoviesPage(try await httpClient.load(resource))
    }
}
