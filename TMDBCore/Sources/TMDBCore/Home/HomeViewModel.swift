import Observation

@MainActor
@Observable
public final class HomeViewModel {

    // MARK: - Trending
    public var trendingTab: TrendingTab = .today
    public private(set) var trendingItems: [SearchResult] = []

    // MARK: - Latest Trailers
    public var trailersTab: TrailersTab = .popular
    public private(set) var trailerItems: [SearchResult] = []
    public private(set) var trailerKeys: [String: String] = [:]
    private var fetchedTrailerIds: Set<String> = []

    // MARK: - What's Popular
    public var popularTab: PopularTab = .streaming
    public private(set) var popularItems: [SearchResult] = []

    // MARK: - Free To Watch
    public var freeTab: FreeTab = .movies
    public private(set) var freeItems: [SearchResult] = []

    // MARK: - Global state
    public var isLoading = false
    public var errorMessage: String?

    // MARK: - Dependencies
    private let service: any HomeServiceProtocol
    private let sessionManager: any SessionManagerProtocol
    private let onLogout: () -> Void

    public init(
        service: any HomeServiceProtocol,
        sessionManager: any SessionManagerProtocol,
        onLogout: @escaping () -> Void
    ) {
        self.service = service
        self.sessionManager = sessionManager
        self.onLogout = onLogout
    }

    // MARK: - Initial load (4 sections in parallel)

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        async let trendingTask = service.fetchTrending(timeWindow: "day", page: 1)
        async let trailersTask = service.fetchPopularMovies(page: 1)
        async let popularTask = service.fetchDiscoverMovies(monetizationType: "flatrate", page: 1)
        async let freeTask = service.fetchDiscoverMovies(monetizationType: "free", page: 1)
        do {
            let (trending, trailers, popular, free) = try await (trendingTask, trailersTask, popularTask, freeTask)
            trendingItems = trending.filter { switch $0 { case .person: false; default: true } }
            trailerItems = trailers.map { .movie($0) }
            popularItems = popular.map { .movie($0) }
            freeItems = free.map { .movie($0) }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Per-section reloads

    public func loadTrending() async {
        let window = trendingTab == .today ? "day" : "week"
        do {
            let results = try await service.fetchTrending(timeWindow: window, page: 1)
            trendingItems = results.filter { switch $0 { case .person: false; default: true } }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func loadTrailers() async {
        do {
            switch trailersTab {
            case .popular:
                let movies = try await service.fetchPopularMovies(page: 1)
                trailerItems = movies.map { .movie($0) }
            case .streaming:
                let movies = try await service.fetchDiscoverMovies(monetizationType: "flatrate", page: 1)
                trailerItems = movies.map { .movie($0) }
            case .onTV:
                let series = try await service.fetchOnTheAir(page: 1)
                trailerItems = series.map { .series($0) }
            case .forRent:
                let movies = try await service.fetchDiscoverMovies(monetizationType: "rent", page: 1)
                trailerItems = movies.map { .movie($0) }
            case .inTheaters:
                let movies = try await service.fetchNowPlaying(page: 1)
                trailerItems = movies.map { .movie($0) }
            }
            // Reset keys when content changes
            fetchedTrailerIds = []
            trailerKeys = [:]
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func loadPopular() async {
        do {
            switch popularTab {
            case .streaming:
                let movies = try await service.fetchDiscoverMovies(monetizationType: "flatrate", page: 1)
                popularItems = movies.map { .movie($0) }
            case .onTV:
                let series = try await service.fetchOnTheAir(page: 1)
                popularItems = series.map { .series($0) }
            case .forRent:
                let movies = try await service.fetchDiscoverMovies(monetizationType: "rent", page: 1)
                popularItems = movies.map { .movie($0) }
            case .inTheaters:
                let movies = try await service.fetchNowPlaying(page: 1)
                popularItems = movies.map { .movie($0) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func loadFree() async {
        do {
            switch freeTab {
            case .movies:
                let movies = try await service.fetchDiscoverMovies(monetizationType: "free", page: 1)
                freeItems = movies.map { .movie($0) }
            case .tv:
                let series = try await service.fetchDiscoverTV(monetizationType: "free", page: 1)
                freeItems = series.map { .series($0) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Lazy trailer key loading

    public func loadTrailerKey(for result: SearchResult) async {
        let resultId = result.id
        guard !fetchedTrailerIds.contains(resultId) else { return }
        fetchedTrailerIds.insert(resultId)
        do {
            let videos: [Video]
            switch result {
            case .movie(let m): videos = try await service.fetchMovieVideos(movieId: m.id)
            case .series(let s): videos = try await service.fetchTVVideos(seriesId: s.id)
            case .person: return
            }
            let trailer = videos.first { $0.site == "YouTube" && ($0.type == "Trailer" || $0.type == "Teaser") }
                        ?? videos.first { $0.site == "YouTube" }
            if let key = trailer?.key {
                trailerKeys[resultId] = key
            }
        } catch {
            fetchedTrailerIds.remove(resultId)
        }
    }

    // MARK: - Logout

    public func logout() {
        sessionManager.clearSession()
        onLogout()
    }
}
