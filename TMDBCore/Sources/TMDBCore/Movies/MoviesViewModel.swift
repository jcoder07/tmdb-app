import Observation

@MainActor
@Observable
public final class MoviesViewModel {

    public private(set) var movies: [Movie] = []       { didSet { recomputeDerived() } }
    public private(set) var displayedMovies: [Movie] = []
    public private(set) var canShowMore = false
    public var isLoading = false
    public var isLoadingMore = false
    public var errorMessage: String?

    private var displayedCount = 8  { didSet { recomputeDerived() } }
    private var currentPage = 1     { didSet { recomputeDerived() } }
    private var totalPages = 1      { didSet { recomputeDerived() } }
    nonisolated(unsafe) private let service: any MoviesServiceProtocol
    nonisolated(unsafe) private let detailService: any MovieDetailServiceProtocol
    private var detailViewModels: [Int: MovieDetailViewModel] = [:]

    public init(service: MoviesServiceProtocol, detailService: MovieDetailServiceProtocol) {
        self.service = service
        self.detailService = detailService
    }

    public func makeDetailViewModel(for movieId: Int) -> MovieDetailViewModel {
        if let existing = detailViewModels[movieId] { return existing }
        let vm = MovieDetailViewModel(movieId: movieId, service: detailService)
        detailViewModels[movieId] = vm
        return vm
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let page = try await service.fetchPopularMovies(page: 1)
            movies = page.movies
            totalPages = page.totalPages
            currentPage = 1
            displayedCount = min(8, page.movies.count)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func showMore() async {
        let nextCount = displayedCount + 8
        if nextCount > movies.count && currentPage < totalPages {
            isLoadingMore = true
            do {
                let page = try await service.fetchPopularMovies(page: currentPage + 1)
                movies += page.movies
                currentPage += 1
            } catch { }
            isLoadingMore = false
        }
        displayedCount = min(nextCount, movies.count)
    }

    private func recomputeDerived() {
        displayedMovies = Array(movies.prefix(displayedCount))
        canShowMore = displayedCount < movies.count || currentPage < totalPages
    }
}
