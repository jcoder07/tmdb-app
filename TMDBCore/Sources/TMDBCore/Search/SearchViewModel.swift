import Observation

@MainActor
@Observable
public final class SearchViewModel {

    public var query: String = ""
    public private(set) var suggestions: [SearchResult] = []
    public private(set) var genres: [GenreItem] = []
    public var isSearching = false
    public var isLoadingGenres = false
    public var errorMessage: String?

    private let searchService: any SearchServiceProtocol
    private let genreService: any GenreServiceProtocol
    private var searchTask: Task<Void, Never>?

    public init(searchService: any SearchServiceProtocol, genreService: any GenreServiceProtocol) {
        self.searchService = searchService
        self.genreService = genreService
    }

    public func loadGenres() async {
        guard genres.isEmpty, !isLoadingGenres else { return }
        isLoadingGenres = true
        do {
            genres = try await genreService.fetchMovieGenres()
        } catch {
            // Genres are non-critical; fail silently
        }
        isLoadingGenres = false
    }

    public func search() {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            suggestions = []
            errorMessage = nil
            return
        }
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                isSearching = true
                let results = try await searchService.searchMulti(query: trimmed, page: 1)
                suggestions = results
                errorMessage = nil
            } catch is CancellationError {
                // Debounce cancelled — leave state unchanged
            } catch {
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }
}
