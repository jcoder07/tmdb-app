import Foundation

public protocol HomeServiceProtocol: Sendable {
    func fetchTrending(timeWindow: String, page: Int) async throws -> [SearchResult]
    func fetchPopularMovies(page: Int) async throws -> [Movie]
    func fetchNowPlaying(page: Int) async throws -> [Movie]
    func fetchOnTheAir(page: Int) async throws -> [Series]
    func fetchDiscoverMovies(monetizationType: String, page: Int) async throws -> [Movie]
    func fetchDiscoverTV(monetizationType: String, page: Int) async throws -> [Series]
    func fetchMovieVideos(movieId: Int) async throws -> [Video]
    func fetchTVVideos(seriesId: Int) async throws -> [Video]
}

public final class HomeService: HomeServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchTrending(timeWindow: String, page: Int) async throws -> [SearchResult] {
        let resource = Resource(url: Constants.Urls.trending(timeWindow: timeWindow, page: page), modelType: MultiSearchResponseDTO.self)
        return try await httpClient.load(resource).results.compactMap(SearchResult.init)
    }

    public func fetchPopularMovies(page: Int) async throws -> [Movie] {
        let resource = Resource(url: Constants.Urls.popularMovies(page: page), modelType: PopularMoviesResponseDTO.self)
        return try await httpClient.load(resource).results.map(Movie.init)
    }

    public func fetchNowPlaying(page: Int) async throws -> [Movie] {
        let resource = Resource(url: Constants.Urls.nowPlayingMovies(page: page), modelType: PopularMoviesResponseDTO.self)
        return try await httpClient.load(resource).results.map(Movie.init)
    }

    public func fetchOnTheAir(page: Int) async throws -> [Series] {
        let resource = Resource(url: Constants.Urls.onTheAirTV(page: page), modelType: PopularSeriesResponseDTO.self)
        return try await httpClient.load(resource).results.map(Series.init)
    }

    public func fetchDiscoverMovies(monetizationType: String, page: Int) async throws -> [Movie] {
        let resource = Resource(url: Constants.Urls.discoverMoviesBy(monetizationType: monetizationType, page: page), modelType: PopularMoviesResponseDTO.self)
        return try await httpClient.load(resource).results.map(Movie.init)
    }

    public func fetchDiscoverTV(monetizationType: String, page: Int) async throws -> [Series] {
        let resource = Resource(url: Constants.Urls.discoverTVBy(monetizationType: monetizationType, page: page), modelType: PopularSeriesResponseDTO.self)
        return try await httpClient.load(resource).results.map(Series.init)
    }

    public func fetchMovieVideos(movieId: Int) async throws -> [Video] {
        let resource = Resource(url: Constants.Urls.movieVideos(id: movieId), modelType: VideoResponseDTO.self)
        return try await httpClient.load(resource).results.map(Video.init)
    }

    public func fetchTVVideos(seriesId: Int) async throws -> [Video] {
        let resource = Resource(url: Constants.Urls.tvVideos(id: seriesId), modelType: VideoResponseDTO.self)
        return try await httpClient.load(resource).results.map(Video.init)
    }
}
