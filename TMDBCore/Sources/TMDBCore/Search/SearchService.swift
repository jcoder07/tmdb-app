import Foundation

public protocol SearchServiceProtocol: Sendable {
    func searchMulti(query: String, page: Int) async throws -> [SearchResult]
    func discoverByGenre(genreId: Int, page: Int) async throws -> (movies: [Movie], series: [Series])
}

public final class SearchService: SearchServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func searchMulti(query: String, page: Int) async throws -> [SearchResult] {
        let resource = Resource(url: Constants.Urls.searchMulti(query: query, page: page), modelType: MultiSearchResponseDTO.self)
        let dto = try await httpClient.load(resource)
        return dto.results.compactMap(SearchResult.init)
    }

    public func discoverByGenre(genreId: Int, page: Int) async throws -> (movies: [Movie], series: [Series]) {
        let moviesResource = Resource(url: Constants.Urls.discoverMovies(genreId: genreId, page: page), modelType: PopularMoviesResponseDTO.self)
        let seriesResource = Resource(url: Constants.Urls.discoverTVShows(genreId: genreId, page: page), modelType: PopularSeriesResponseDTO.self)
        async let moviesDTO = httpClient.load(moviesResource)
        async let seriesDTO = httpClient.load(seriesResource)
        let (movies, series) = try await (moviesDTO, seriesDTO)
        return (movies: movies.results.map(Movie.init), series: series.results.map(Series.init))
    }
}
