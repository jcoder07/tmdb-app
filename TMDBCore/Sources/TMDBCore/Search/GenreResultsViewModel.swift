import Observation

@MainActor
@Observable
public final class GenreResultsViewModel {

    public let genre: GenreItem
    public private(set) var movies: [Movie] = []
    public private(set) var series: [Series] = []
    public var isLoading = false
    public var errorMessage: String?

    private let service: any SearchServiceProtocol

    public init(genre: GenreItem, service: any SearchServiceProtocol) {
        self.genre = genre
        self.service = service
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let result = try await service.discoverByGenre(genreId: genre.id, page: 1)
            movies = result.movies
            series = result.series
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
