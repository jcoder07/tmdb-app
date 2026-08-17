import Foundation
import TMDBCore
@testable import TMDBSwiftUI

/// In-memory session manager for flows where session *content* is the input under test
/// (Watchlist, Home) rather than session *persistence* itself. Keychain persistence is
/// covered separately by SessionPersistenceIntegrationTests against the real `SessionManager`.
final class InMemorySessionManager: SessionManagerProtocol, @unchecked Sendable {
    private var storedId: String?

    init(seedSessionId: String? = nil) {
        storedId = seedSessionId
    }

    func saveSession(id: String) { storedId = id }
    func getSession() -> String? { storedId }
    func clearSession() { storedId = nil }
    var isLoggedIn: Bool { storedId != nil }
}

/// Wires the real production stack — services, the SwiftUI-target decorator, and ViewModels —
/// against a stubbed network. Mirrors the composition in `TMDBSwiftUIApp.swift` without
/// modifying it, per the review decision to leave the app's composition root untouched.
struct IntegrationStack {
    let httpClient: HttpClientProtocol
    let sessionManager: InMemorySessionManager

    init(seedSessionId: String? = nil) {
        StubURLProtocol.reset()
        httpClient = HttpClient(sessionProvider: StubURLProtocol.makeSession)
        sessionManager = InMemorySessionManager(seedSessionId: seedSessionId)
    }

    func stub(
        path: String,
        matchingQuery: (@Sendable ([URLQueryItem]) -> Bool)? = nil,
        statusCode: Int = 200,
        json: String
    ) {
        StubURLProtocol.stub(path: path, matchingQuery: matchingQuery, statusCode: statusCode, json: json)
    }

    var recordedRequests: [StubURLProtocol.RecordedRequest] {
        StubURLProtocol.recordedRequests
    }

    var unexpectedRequestURLs: [URL] {
        StubURLProtocol.unexpectedRequestURLs
    }

    // MARK: - Real services

    var authService: any TMDBAuthServiceProtocol { TMDBAuthService(httpClient: httpClient) }
    var moviesService: any MoviesServiceProtocol { MoviesService(httpClient: httpClient) }
    var watchlistService: any WatchlistServiceProtocol { WatchlistService(httpClient: httpClient) }
    var homeService: any HomeServiceProtocol { HomeService(httpClient: httpClient) }
    var accountService: any AccountServiceProtocol {
        AccountServiceCacheDecorator(decoratee: AccountService(httpClient: httpClient))
    }

    // MARK: - Real ViewModels

    @MainActor
    func makeLoginViewModel(onLoginSuccess: @escaping () -> Void = {}) -> LoginViewModel {
        LoginViewModel(sessionManager: sessionManager, authService: authService, onLoginSuccess: onLoginSuccess)
    }

    @MainActor
    func makeMoviesViewModel() -> MoviesViewModel {
        MoviesViewModel(service: moviesService)
    }

    @MainActor
    func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(service: watchlistService, accountService: accountService, sessionManager: sessionManager)
    }

    @MainActor
    func makeHomeViewModel(onLogout: @escaping () -> Void = {}) -> HomeViewModel {
        HomeViewModel(service: homeService, sessionManager: sessionManager, onLogout: onLogout)
    }
}
