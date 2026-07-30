import Observation

@MainActor
@Observable
public final class BrowseResultsViewModel {

    public let kind: BrowseKind
    public private(set) var movies: [Movie] = []
    public private(set) var series: [Series] = []
    public private(set) var people: [PersonSummary] = []
    public var isLoading = false
    public var errorMessage: String?

    private let moviesService: any MoviesServiceProtocol
    private let seriesService: any SeriesServiceProtocol
    private let personService: any PersonServiceProtocol

    public init(
        kind: BrowseKind,
        moviesService: any MoviesServiceProtocol,
        seriesService: any SeriesServiceProtocol,
        personService: any PersonServiceProtocol
    ) {
        self.kind = kind
        self.moviesService = moviesService
        self.seriesService = seriesService
        self.personService = personService
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            switch kind {
            case .movies:
                let page = try await moviesService.fetchPopularMovies(page: 1)
                movies = page.movies
            case .tv:
                let page = try await seriesService.fetchPopularSeries(page: 1)
                series = page.series
            case .people:
                people = try await personService.fetchPopular(page: 1)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
