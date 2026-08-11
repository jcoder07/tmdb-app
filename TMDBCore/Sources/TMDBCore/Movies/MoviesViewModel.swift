import Observation

@MainActor
@Observable
public final class MoviesViewModel {

    public private(set) var movies: [Movie] = []
    public private(set) var hasMorePages = false
    public var isLoading = false
    public var isLoadingMore = false
    public var errorMessage: String?

    private var currentPage = 1
    private var totalPages = 1
    private let service: any MoviesServiceProtocol

    public init(service: MoviesServiceProtocol) {
        self.service = service
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
            hasMorePages = currentPage < totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    public func loadNextPage() async {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        do {
            let page = try await service.fetchPopularMovies(page: currentPage + 1)
            let existingIds = Set(movies.map(\.id))
            movies += page.movies.filter { !existingIds.contains($0.id) }
            currentPage += 1
            hasMorePages = currentPage < totalPages
        } catch { }
        isLoadingMore = false
    }
}
