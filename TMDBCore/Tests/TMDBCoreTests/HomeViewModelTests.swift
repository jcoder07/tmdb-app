import Testing
@testable import TMDBCore

// Uses DummySessionManager, StubHomeService, SpySessionManager from TestDoubles.swift

@MainActor
struct HomeViewModelTests {

    private func makeSUT(
        service: any HomeServiceProtocol = StubHomeService(),
        sessionManager: any SessionManagerProtocol = DummySessionManager(),
        onLogout: @escaping () -> Void = {}
    ) -> HomeViewModel {
        HomeViewModel(service: service, sessionManager: sessionManager, onLogout: onLogout)
    }

    // MARK: - load()

    @Test func loadPopulatesAllFourSections_usingStubService() async {
        let stub = StubHomeService()
        stub.trendingResults = [.movie(makeMovie(id: 1))]
        stub.popularMovies = [makeMovie(id: 2)]
        stub.discoverMovies = [makeMovie(id: 3)]
        let sut = makeSUT(service: stub)

        await sut.load()

        #expect(sut.trendingItems.count == 1)
        #expect(sut.trailerItems.count == 1)
        #expect(sut.popularItems.count == 1)
        #expect(sut.freeItems.count == 1)
    }

    @Test func loadFiltersPeopleResultsFromTrending_usingStubService() async {
        let stub = StubHomeService()
        let person = PersonSummary(id: 99, name: "Actor", profileURL: nil, knownForText: "")
        stub.trendingResults = [
            .movie(makeMovie(id: 1)),
            .person(person),
            .series(makeSeries(id: 5))
        ]
        let sut = makeSUT(service: stub)

        await sut.load()

        #expect(sut.trendingItems.count == 2)
    }

    @Test func loadSetsErrorMessageOnFailure_usingStubService() async {
        let stub = StubHomeService()
        stub.errorToThrow = NetworkError.invalidResponse
        let sut = makeSUT(service: stub)

        await sut.load()

        #expect(sut.errorMessage != nil)
    }

    @Test func loadSetsIsLoadingFalseAfterCompletion_usingStubService() async {
        let sut = makeSUT()
        await sut.load()
        #expect(sut.isLoading == false)
    }

    @Test func loadDoesNotReloadWhileInProgress_usingStubService() async {
        final class CountingHomeService: HomeServiceProtocol, @unchecked Sendable {
            var trendingCallCount = 0
            func fetchTrending(timeWindow: String, page: Int) async throws -> [SearchResult] { trendingCallCount += 1; return [] }
            func fetchPopularMovies(page: Int) async throws -> [Movie] { [] }
            func fetchNowPlaying(page: Int) async throws -> [Movie] { [] }
            func fetchOnTheAir(page: Int) async throws -> [Series] { [] }
            func fetchDiscoverMovies(monetizationType: String, page: Int) async throws -> [Movie] { [] }
            func fetchDiscoverTV(monetizationType: String, page: Int) async throws -> [Series] { [] }
            func fetchMovieVideos(movieId: Int) async throws -> [Video] { [] }
            func fetchTVVideos(seriesId: Int) async throws -> [Video] { [] }
        }
        let counting = CountingHomeService()
        let sut = makeSUT(service: counting)
        sut.isLoading = true  // simulate in-flight load

        await sut.load()

        #expect(counting.trendingCallCount == 0)
    }

    // MARK: - loadTrending()

    @Test func loadTrendingFetchesDayWindowByDefault_usingStubService() async {
        final class CapturingHomeService: HomeServiceProtocol, @unchecked Sendable {
            var lastTimeWindow = ""
            func fetchTrending(timeWindow: String, page: Int) async throws -> [SearchResult] { lastTimeWindow = timeWindow; return [] }
            func fetchPopularMovies(page: Int) async throws -> [Movie] { [] }
            func fetchNowPlaying(page: Int) async throws -> [Movie] { [] }
            func fetchOnTheAir(page: Int) async throws -> [Series] { [] }
            func fetchDiscoverMovies(monetizationType: String, page: Int) async throws -> [Movie] { [] }
            func fetchDiscoverTV(monetizationType: String, page: Int) async throws -> [Series] { [] }
            func fetchMovieVideos(movieId: Int) async throws -> [Video] { [] }
            func fetchTVVideos(seriesId: Int) async throws -> [Video] { [] }
        }
        let capturing = CapturingHomeService()
        let sut = makeSUT(service: capturing)

        await sut.loadTrending()

        #expect(capturing.lastTimeWindow == "day")
    }

    @Test func loadTrendingFetchesWeekWindowWhenTabIsThisWeek_usingStubService() async {
        final class CapturingHomeService: HomeServiceProtocol, @unchecked Sendable {
            var lastTimeWindow = ""
            func fetchTrending(timeWindow: String, page: Int) async throws -> [SearchResult] { lastTimeWindow = timeWindow; return [] }
            func fetchPopularMovies(page: Int) async throws -> [Movie] { [] }
            func fetchNowPlaying(page: Int) async throws -> [Movie] { [] }
            func fetchOnTheAir(page: Int) async throws -> [Series] { [] }
            func fetchDiscoverMovies(monetizationType: String, page: Int) async throws -> [Movie] { [] }
            func fetchDiscoverTV(monetizationType: String, page: Int) async throws -> [Series] { [] }
            func fetchMovieVideos(movieId: Int) async throws -> [Video] { [] }
            func fetchTVVideos(seriesId: Int) async throws -> [Video] { [] }
        }
        let capturing = CapturingHomeService()
        let sut = makeSUT(service: capturing)
        sut.trendingTab = .thisWeek

        await sut.loadTrending()

        #expect(capturing.lastTimeWindow == "week")
    }

    // MARK: - logout()

    @Test func logoutClearsSessionAndCallsCallback_usingSpySessionManager() {
        let spy = SpySessionManager()
        spy.seedSession(id: "active-session")
        var logoutCalled = false
        let sut = makeSUT(sessionManager: spy, onLogout: { logoutCalled = true })

        sut.logout()

        #expect(spy.clearSessionCallCount == 1)
        #expect(logoutCalled == true)
    }

    // MARK: - loadTrailerKey()

    @Test func loadTrailerKeyStoresYouTubeTrailerKey_usingStubService() async {
        let stub = StubHomeService()
        stub.movieVideos = [
            Video(id: "v1", key: "abc123", site: "YouTube", type: "Trailer", official: true)
        ]
        let movie = makeMovie(id: 10)
        let sut = makeSUT(service: stub)

        await sut.loadTrailerKey(for: .movie(movie))

        #expect(sut.trailerKeys["movie-10"] == "abc123")
    }

    @Test func loadTrailerKeyPrefersTeaserWhenNoTrailer_usingStubService() async {
        let stub = StubHomeService()
        stub.movieVideos = [
            Video(id: "v1", key: "teaser-key", site: "YouTube", type: "Teaser", official: false)
        ]
        let movie = makeMovie(id: 7)
        let sut = makeSUT(service: stub)

        await sut.loadTrailerKey(for: .movie(movie))

        #expect(sut.trailerKeys["movie-7"] == "teaser-key")
    }

    @Test func loadTrailerKeyIsNotFetchedTwiceForSameItem_usingSpyService() async {
        final class CountingService: HomeServiceProtocol, @unchecked Sendable {
            var videoCallCount = 0
            func fetchTrending(timeWindow: String, page: Int) async throws -> [SearchResult] { [] }
            func fetchPopularMovies(page: Int) async throws -> [Movie] { [] }
            func fetchNowPlaying(page: Int) async throws -> [Movie] { [] }
            func fetchOnTheAir(page: Int) async throws -> [Series] { [] }
            func fetchDiscoverMovies(monetizationType: String, page: Int) async throws -> [Movie] { [] }
            func fetchDiscoverTV(monetizationType: String, page: Int) async throws -> [Series] { [] }
            func fetchMovieVideos(movieId: Int) async throws -> [Video] {
                videoCallCount += 1
                return [Video(id: "v1", key: "k", site: "YouTube", type: "Trailer", official: true)]
            }
            func fetchTVVideos(seriesId: Int) async throws -> [Video] { [] }
        }
        let counting = CountingService()
        let movie = makeMovie(id: 5)
        let sut = makeSUT(service: counting)

        await sut.loadTrailerKey(for: .movie(movie))
        await sut.loadTrailerKey(for: .movie(movie))  // second call should be a no-op

        #expect(counting.videoCallCount == 1)
    }

    @Test func loadTrailerKeyIgnoresPersonResults_usingStubService() async {
        let stub = StubHomeService()
        let person = PersonSummary(id: 1, name: "Actor", profileURL: nil, knownForText: "")
        let sut = makeSUT(service: stub)

        await sut.loadTrailerKey(for: .person(person))

        #expect(sut.trailerKeys.isEmpty)
    }
}
