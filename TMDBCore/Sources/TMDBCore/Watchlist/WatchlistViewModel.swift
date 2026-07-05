import Foundation
import Observation

@MainActor
@Observable
public final class WatchlistViewModel {

    public enum Tab { case movies, tvShows }

    public var selectedTab: Tab = .movies
    public var movies: [WatchlistMovie] = []
    public var tvShows: [WatchlistTVShow] = []
    public var isLoading = false
    public var isLoadingMore = false
    public var errorMessage: String?
    public var canLoadMoreMovies = false
    public var canLoadMoreTVShows = false

    private let service: any WatchlistServiceProtocol
    private let accountService: any AccountServiceProtocol
    private let sessionManager: any SessionManagerProtocol
    private var cachedAccountId: Int?
    private var moviePage = 0
    private var movieTotalPages = 0
    private var tvPage = 0
    private var tvTotalPages = 0

    public init(service: WatchlistServiceProtocol, accountService: AccountServiceProtocol, sessionManager: SessionManagerProtocol) {
        self.service = service
        self.accountService = accountService
        self.sessionManager = sessionManager
    }

    public func load() async {
        guard !isLoading else { return }
        guard let sessionId = sessionManager.getSession() else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let accountId: Int
            if let cached = cachedAccountId {
                accountId = cached
            } else {
                let profile = try await accountService.fetchAccountDetails(sessionId: sessionId)
                accountId = profile.id
                cachedAccountId = accountId
            }
            async let moviesTask = service.fetchMovies(accountId: accountId, sessionId: sessionId, page: 1)
            async let tvShowsTask = service.fetchTVShows(accountId: accountId, sessionId: sessionId, page: 1)
            let (moviesResult, tvResult) = try await (moviesTask, tvShowsTask)
            movies = moviesResult.items
            movieTotalPages = moviesResult.totalPages
            moviePage = 1
            canLoadMoreMovies = moviePage < movieTotalPages
            tvShows = tvResult.items
            tvTotalPages = tvResult.totalPages
            tvPage = 1
            canLoadMoreTVShows = tvPage < tvTotalPages
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
        }
    }

    public func loadMore() async {
        guard let sessionId = sessionManager.getSession(), let accountId = cachedAccountId else { return }
        guard !isLoadingMore else { return }
        isLoadingMore = true
        do {
            switch selectedTab {
            case .movies:
                guard moviePage < movieTotalPages else { break }
                let nextPage = moviePage + 1
                let result = try await service.fetchMovies(accountId: accountId, sessionId: sessionId, page: nextPage)
                movies += result.items
                moviePage = nextPage
                movieTotalPages = result.totalPages
                canLoadMoreMovies = moviePage < movieTotalPages
            case .tvShows:
                guard tvPage < tvTotalPages else { break }
                let nextPage = tvPage + 1
                let result = try await service.fetchTVShows(accountId: accountId, sessionId: sessionId, page: nextPage)
                tvShows += result.items
                tvPage = nextPage
                tvTotalPages = result.totalPages
                canLoadMoreTVShows = tvPage < tvTotalPages
            }
        } catch { }
        isLoadingMore = false
    }
}
