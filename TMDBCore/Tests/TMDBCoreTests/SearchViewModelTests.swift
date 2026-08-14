import Testing
@testable import TMDBCore

// Uses StubSearchService, StubGenreService from TestDoubles.swift

@MainActor
struct SearchViewModelTests {

    private func makeSUT(
        searchService: any SearchServiceProtocol = StubSearchService(),
        genreService: any GenreServiceProtocol = StubGenreService()
    ) -> SearchViewModel {
        SearchViewModel(searchService: searchService, genreService: genreService)
    }

    // MARK: - loadGenres()

    @Test func loadGenresSetsGenresFromService_usingStubGenreService() async {
        let stub = StubGenreService()
        stub.movieGenres = [GenreItem(id: 28, name: "Action"), GenreItem(id: 35, name: "Comedy")]
        let sut = makeSUT(genreService: stub)

        await sut.loadGenres()

        #expect(sut.genres.count == 2)
        #expect(sut.genres[0].name == "Action")
        #expect(sut.genres[1].name == "Comedy")
    }

    @Test func loadGenresIsIdempotentOnSecondCall_usingSpyGenreService() async {
        final class CountingGenreService: GenreServiceProtocol, @unchecked Sendable {
            var callCount = 0
            func fetchMovieGenres() async throws -> [GenreItem] {
                callCount += 1
                return [GenreItem(id: 1, name: "Action")]
            }
            func fetchTVGenres() async throws -> [GenreItem] { [] }
        }
        let counting = CountingGenreService()
        let sut = makeSUT(genreService: counting)

        await sut.loadGenres()
        await sut.loadGenres()  // genres already populated – should skip

        #expect(counting.callCount == 1)
    }

    @Test func loadGenresSilentlyFailsOnError_usingStubGenreService() async {
        let stub = StubGenreService()
        stub.errorToThrow = NetworkError.invalidResponse
        let sut = makeSUT(genreService: stub)

        await sut.loadGenres()

        #expect(sut.genres.isEmpty)
        #expect(sut.errorMessage == nil)  // genres fail silently per design
        #expect(sut.isLoadingGenres == false)
    }

    @Test func loadGenresSetsIsLoadingGenresFalseOnCompletion_usingStubGenreService() async {
        let sut = makeSUT()
        await sut.loadGenres()
        #expect(sut.isLoadingGenres == false)
    }

    // MARK: - search() – synchronous entry point

    @Test func searchWithWhitespaceOnlyClearsSuggestions_usingStubSearchService() {
        let sut = makeSUT()
        sut.query = "   "

        sut.search()

        #expect(sut.suggestions.isEmpty)
        #expect(sut.errorMessage == nil)
    }

    @Test func searchWithEmptyStringClearsSuggestions_usingStubSearchService() {
        let sut = makeSUT()
        sut.query = ""

        sut.search()

        #expect(sut.suggestions.isEmpty)
    }

    @Test func searchPopulatesSuggestionsAfterDebounce_usingStubSearchService() async throws {
        let stub = StubSearchService()
        stub.results = [.movie(makeMovie(id: 1)), .movie(makeMovie(id: 2))]
        let sut = makeSUT(searchService: stub)
        sut.query = "batman"

        sut.search()
        try await Task.sleep(for: .milliseconds(400))  // wait past the 300ms debounce

        #expect(sut.suggestions.count == 2)
        #expect(sut.isSearching == false)
    }

    @Test func searchSetsErrorMessageOnServiceFailure_usingStubSearchService() async throws {
        let stub = StubSearchService()
        stub.errorToThrow = NetworkError.serverError("Service unavailable")
        let sut = makeSUT(searchService: stub)
        sut.query = "batman"

        sut.search()
        try await Task.sleep(for: .milliseconds(400))

        #expect(sut.errorMessage != nil)
        #expect(sut.isSearching == false)
    }

    @Test func searchCancelsPreviousSearchOnNewQuery_usingStubSearchService() async throws {
        final class CountingSearchService: SearchServiceProtocol, @unchecked Sendable {
            var callCount = 0
            func searchMulti(query: String, page: Int) async throws -> [SearchResult] {
                callCount += 1
                return []
            }
            func discoverByGenre(genreId: Int, page: Int) async throws -> (movies: [Movie], series: [Series]) {
                (movies: [], series: [])
            }
        }
        let counting = CountingSearchService()
        let sut = makeSUT(searchService: counting)

        sut.query = "bat"
        sut.search()
        sut.query = "batman"
        sut.search()  // cancels previous, starts new

        try await Task.sleep(for: .milliseconds(450))

        // Only the last search should have completed
        #expect(counting.callCount == 1)
    }
}
