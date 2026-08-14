import Testing
@testable import TMDBCore

// Uses DummySessionManager, FakeSessionManager, FakeWatchlistService,
// StubAccountService, MockAccountService, MockWatchlistService from TestDoubles.swift

@MainActor
struct WatchlistViewModelTests {

    private func makeSUT(
        service: any WatchlistServiceProtocol = FakeWatchlistService(),
        accountService: any AccountServiceProtocol = StubAccountService(),
        sessionManager: any SessionManagerProtocol = FakeSessionManager()
    ) -> WatchlistViewModel {
        WatchlistViewModel(service: service, accountService: accountService, sessionManager: sessionManager)
    }

    // MARK: - load() – guard without session

    @Test func loadDoesNothingWithoutSession_usingDummySessionManager() async {
        // Dummy always returns nil from getSession(), so load() exits early.
        let dummy = DummySessionManager()
        let sut = makeSUT(sessionManager: dummy)

        await sut.load()

        #expect(sut.movies.isEmpty)
        #expect(sut.tvShows.isEmpty)
        #expect(sut.isLoading == false)
    }

    // MARK: - load() – success paths

    @Test func loadPopulatesMoviesAndTVShows_usingFakeService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session-123")
        let fakeService = FakeWatchlistService()
        fakeService.movies = [makeWatchlistMovie(id: 1), makeWatchlistMovie(id: 2)]
        fakeService.tvShows = [makeWatchlistTVShow(id: 10)]
        let sut = makeSUT(service: fakeService, sessionManager: fakeSession)

        await sut.load()

        #expect(sut.movies.count == 2)
        #expect(sut.tvShows.count == 1)
        #expect(sut.isLoading == false)
    }

    @Test func loadSetsCanLoadMoreMoviesWhenMultiplePages_usingFakeService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "s")
        let fakeService = FakeWatchlistService()
        fakeService.movies = [makeWatchlistMovie(id: 1)]
        fakeService.totalMoviePages = 3
        let sut = makeSUT(service: fakeService, sessionManager: fakeSession)

        await sut.load()

        #expect(sut.canLoadMoreMovies == true)
    }

    @Test func loadDoesNotReloadWhileInProgress_usingFakeService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "s")

        final class CountingService: WatchlistServiceProtocol, @unchecked Sendable {
            var fetchMoviesCallCount = 0
            func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
                fetchMoviesCallCount += 1
                return (items: [], totalPages: 1)
            }
            func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) { (items: [], totalPages: 1) }
            func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {}
            func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {}
        }
        let counting = CountingService()
        let sut = makeSUT(service: counting, sessionManager: fakeSession)
        sut.isLoading = true

        await sut.load()

        #expect(counting.fetchMoviesCallCount == 0)
    }

    @Test func loadCachesAccountId_usingMockAccountService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session")
        let fakeService = FakeWatchlistService()
        let mockAccount = MockAccountService()
        mockAccount.expectedFetchDetailsCount = 1  // expect exactly ONE account fetch across two load() calls

        let sut = makeSUT(service: fakeService, accountService: mockAccount, sessionManager: fakeSession)

        await sut.load()
        await sut.load()  // second call: uses cachedAccountId, no new fetch

        mockAccount.verify()
    }

    @Test func loadSetsErrorMessageOnServiceFailure() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session")

        final class FailingService: WatchlistServiceProtocol, @unchecked Sendable {
            func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
                throw NetworkError.invalidResponse
            }
            func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) {
                throw NetworkError.invalidResponse
            }
            func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {}
            func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {}
        }

        let sut = makeSUT(service: FailingService(), sessionManager: fakeSession)

        await sut.load()

        #expect(sut.errorMessage != nil)
    }

    // MARK: - removeMovie()

    @Test func removeMovieRemovesFromLocalListAndCallsService_usingMockService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session")
        let mock = MockWatchlistService()
        mock.moviesToReturn = [makeWatchlistMovie(id: 1), makeWatchlistMovie(id: 2)]
        mock.expectedRemovedMovieIds = [1]
        let sut = makeSUT(service: mock, sessionManager: fakeSession)

        await sut.load()
        await sut.removeMovie(id: 1)

        #expect(sut.movies.count == 1)
        #expect(sut.movies[0].id == 2)
        mock.verify()
    }

    @Test func removeMovieRevertsLocalListOnServiceError_usingMockService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session")
        let mock = MockWatchlistService()
        mock.moviesToReturn = [makeWatchlistMovie(id: 1), makeWatchlistMovie(id: 2)]
        mock.removeMovieErrorToThrow = NetworkError.serverError("Failed")
        let sut = makeSUT(service: mock, sessionManager: fakeSession)

        await sut.load()
        await sut.removeMovie(id: 1)

        // Movie was removed optimistically, then re-inserted at front on failure
        #expect(sut.movies.contains(where: { $0.id == 1 }))
    }

    @Test func removeMovieDoesNothingWithoutSession() async {
        // DummySessionManager returns nil -> removeMovie guard fails
        let dummy = DummySessionManager()
        let mock = MockWatchlistService()
        mock.moviesToReturn = [makeWatchlistMovie(id: 1)]
        mock.expectedRemovedMovieIds = []
        let sut = makeSUT(service: mock, sessionManager: dummy)

        await sut.removeMovie(id: 1)

        mock.verify()
    }

    // MARK: - removeTVShow()

    @Test func removeTVShowRemovesFromLocalListAndCallsService_usingMockService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session")
        let mock = MockWatchlistService()
        mock.tvShowsToReturn = [makeWatchlistTVShow(id: 10), makeWatchlistTVShow(id: 20)]
        mock.expectedRemovedTVIds = [10]
        let sut = makeSUT(service: mock, sessionManager: fakeSession)

        await sut.load()
        await sut.removeTVShow(id: 10)

        #expect(sut.tvShows.count == 1)
        #expect(sut.tvShows[0].id == 20)
        mock.verify()
    }

    @Test func removeTVShowRevertsLocalListOnError_usingMockService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session")
        let mock = MockWatchlistService()
        mock.tvShowsToReturn = [makeWatchlistTVShow(id: 10)]
        mock.removeTVErrorToThrow = NetworkError.serverError("Error")
        let sut = makeSUT(service: mock, sessionManager: fakeSession)

        await sut.load()
        await sut.removeTVShow(id: 10)

        #expect(sut.tvShows.contains(where: { $0.id == 10 }))
    }

    // MARK: - loadMore()

    @Test func loadMoreAppendsMoviesWhenMorePagesAvailable_usingFakeService() async {
        let fakeSession = FakeSessionManager()
        fakeSession.saveSession(id: "session")

        final class PaginatedService: WatchlistServiceProtocol, @unchecked Sendable {
            var page1Movies = [WatchlistMovie]()
            var page2Movies = [WatchlistMovie]()

            func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
                page == 1 ? (items: page1Movies, totalPages: 2) : (items: page2Movies, totalPages: 2)
            }
            func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) {
                (items: [], totalPages: 1)
            }
            func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {}
            func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {}
        }

        let paged = PaginatedService()
        paged.page1Movies = [makeWatchlistMovie(id: 1)]
        paged.page2Movies = [makeWatchlistMovie(id: 2)]

        let sut = makeSUT(service: paged, sessionManager: fakeSession)

        await sut.load()        // loads page 1
        await sut.loadMore()    // loads page 2

        #expect(sut.movies.count == 2)
        #expect(sut.movies.map(\.id) == [1, 2])
    }
}
