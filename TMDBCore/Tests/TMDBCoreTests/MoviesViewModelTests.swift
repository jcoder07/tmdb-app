import Testing
@testable import TMDBCore

// Uses StubMoviesService and SpyMoviesService from TestDoubles.swift

@MainActor
struct MoviesViewModelTests {

    // MARK: - load()

    @Test func loadSetsMovies_usingStubService() async {
        let stub = StubMoviesService(movies: [makeMovie(id: 1), makeMovie(id: 2)], totalPages: 1)
        let sut = MoviesViewModel(service: stub)

        await sut.load()

        #expect(sut.movies.count == 2)
        #expect(sut.movies[0].id == 1)
        #expect(sut.movies[1].id == 2)
    }

    @Test func loadSetsHasMorePagesWhenMultiplePages_usingStubService() async {
        let stub = StubMoviesService(movies: [makeMovie(id: 1)], totalPages: 3)
        let sut = MoviesViewModel(service: stub)

        await sut.load()

        #expect(sut.hasMorePages == true)
    }

    @Test func loadWithSinglePageHasNoMorePages_usingStubService() async {
        let stub = StubMoviesService(movies: [makeMovie(id: 1)], totalPages: 1)
        let sut = MoviesViewModel(service: stub)

        await sut.load()

        #expect(sut.hasMorePages == false)
    }

    @Test func loadClearsErrorAndSetsIsLoadingFalseOnSuccess_usingStubService() async {
        let stub = StubMoviesService(movies: [])
        let sut = MoviesViewModel(service: stub)

        await sut.load()

        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test func loadSetsErrorMessageAndKeepsIsLoadingFalseOnFailure_usingStubService() async {
        let stub = StubMoviesService()
        stub.errorToThrow = NetworkError.invalidResponse
        let sut = MoviesViewModel(service: stub)

        await sut.load()

        #expect(sut.errorMessage != nil)
        #expect(sut.movies.isEmpty)
        #expect(sut.isLoading == false)
    }

    @Test func loadGuardsAgainstConcurrentCalls_usingSpyService() async {
        // Spy records all page fetches; if the guard works, load() while
        // isLoading == true must not trigger another fetch.
        let spy = SpyMoviesService()
        let sut = MoviesViewModel(service: spy)
        sut.isLoading = true  // simulate in-flight load

        await sut.load()

        #expect(spy.fetchedPages.isEmpty)
    }

    @Test func loadAlwaysFetchesPage1_usingSpyService() async {
        let spy = SpyMoviesService()
        let sut = MoviesViewModel(service: spy)

        await sut.load()

        #expect(spy.fetchedPages == [1])
    }

    @Test func loadResetsToPage1OnReload_usingSpyService() async {
        let spy = SpyMoviesService()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 1)], page: 1, totalPages: 2)
        let sut = MoviesViewModel(service: spy)

        await sut.load()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 2)], page: 2, totalPages: 2)
        await sut.loadNextPage()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 3)], page: 1, totalPages: 1)
        await sut.load()  // second full load

        #expect(spy.fetchedPages == [1, 2, 1])
        #expect(sut.movies.count == 1)
        #expect(sut.movies[0].id == 3)
    }

    // MARK: - loadNextPage()

    @Test func loadNextPageFetchesPage2_usingSpyService() async {
        let spy = SpyMoviesService()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 1)], page: 1, totalPages: 2)
        let sut = MoviesViewModel(service: spy)

        await sut.load()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 2)], page: 2, totalPages: 2)
        await sut.loadNextPage()

        #expect(spy.fetchedPages == [1, 2])
        #expect(sut.movies.count == 2)
    }

    @Test func loadNextPageFiltersOutDuplicateIDs_usingSpyService() async {
        let spy = SpyMoviesService()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 10), makeMovie(id: 11)], page: 1, totalPages: 2)
        let sut = MoviesViewModel(service: spy)

        await sut.load()
        // page 2 contains a duplicate (id: 10) and a new item (id: 12)
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 10), makeMovie(id: 12)], page: 2, totalPages: 2)
        await sut.loadNextPage()

        let ids = sut.movies.map(\.id)
        #expect(ids == [10, 11, 12])
    }

    @Test func loadNextPageDoesNothingWhenNoMorePages_usingSpyService() async {
        let spy = SpyMoviesService()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 1)], page: 1, totalPages: 1)
        let sut = MoviesViewModel(service: spy)

        await sut.load()
        await sut.loadNextPage()

        #expect(spy.fetchedPages == [1])
    }

    @Test func loadNextPageSetsIsLoadingMoreFalseOnCompletion_usingSpyService() async {
        let spy = SpyMoviesService()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 1)], page: 1, totalPages: 2)
        let sut = MoviesViewModel(service: spy)

        await sut.load()
        spy.pageToReturn = MoviesPage(movies: [makeMovie(id: 2)], page: 2, totalPages: 2)
        await sut.loadNextPage()

        #expect(sut.isLoadingMore == false)
    }
}
