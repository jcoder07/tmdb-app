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
    public var errorMessage: String?

    private let service: any WatchlistServiceProtocol
    private let sessionManager: any SessionManagerProtocol

    public init(service: WatchlistServiceProtocol, sessionManager: SessionManagerProtocol) {
        self.service = service
        self.sessionManager = sessionManager
    }

    public func load() async {
        guard let sessionId = sessionManager.getSession() else { return }
        isLoading = true
        errorMessage = nil
        do {
            let accountId = try await service.fetchAccountId(sessionId: sessionId)
            async let moviesTask  = service.fetchMovies(accountId: accountId, sessionId: sessionId)
            async let tvShowsTask = service.fetchTVShows(accountId: accountId, sessionId: sessionId)
            (movies, tvShows) = try await (moviesTask, tvShowsTask)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
