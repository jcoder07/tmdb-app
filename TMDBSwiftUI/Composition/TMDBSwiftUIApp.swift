//
//  TMDBSwiftUIApp.swift
//  TMDBSwiftUI
//
//  Created by Miguel Duran on 26-06-26.
//

import SwiftUI
import TMDBCore

@main
struct TMDBSwiftUIApp: App {
    private let sessionManager: SessionManagerProtocol = SessionManager()
    private let httpClient: HttpClientProtocol = HttpClient()

    var body: some Scene {
        WindowGroup {
            AppRootView(
                sessionManager: sessionManager,
                httpClient: httpClient
            )
        }
    }
}

private struct AppRootView: View {
    private let sessionManager: SessionManagerProtocol
    private let httpClient: HttpClientProtocol
    private let authService: TMDBAuthServiceProtocol
    private let accountService: AccountServiceProtocol
    
    @State private var isLoggedIn: Bool

    init(
        sessionManager: SessionManagerProtocol,
        httpClient: HttpClientProtocol
    ) {
        self.sessionManager = sessionManager
        self.httpClient = httpClient
        self.authService = TMDBAuthService(httpClient: httpClient)
        self._isLoggedIn = State(initialValue: sessionManager.isLoggedIn)
        self.accountService = AccountServiceAnalyticsDecorator(
            decoratee: AccountServiceCacheDecorator(
                decoratee: AccountServiceLoggerDecorator(decoratee: AccountService(httpClient: httpClient))
            )
        )
    }

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(
                    homeViewModel: makeHomeViewModel(),
                    moviesViewModel: makeMoviesViewModel(),
                    seriesViewModel: makeSeriesViewModel(),
                    watchlistViewModel: makeWatchlistViewModel(),
                    favoritesViewModel: makeFavoritesViewModel(),
                    myStuffViewModel: makeMyStuffViewModel(),
                    profileViewModel: makeProfileViewModel(),
                    makeMovieDetailViewModel: { self.makeMovieDetailViewModel(for: $0) },
                    makeSeriesDetailViewModel: { self.makeSeriesDetailViewModel(for: $0) }
                )
            } else {
                NavigationStack {
                    LoginView(viewModel: makeLoginViewModel())
                }
            }
        }
    }

    private func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            sessionManager: sessionManager,
            authService: authService,
            onLoginSuccess: {
                isLoggedIn = true
            }
        )
    }

    private func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            sessionManager: sessionManager,
            onLogout: logout
        )
    }

    private func makeSeriesViewModel() -> SeriesViewModel {
        SeriesViewModel(service: SeriesService(httpClient: httpClient))
    }

    private func makeMoviesViewModel() -> MoviesViewModel {
        MoviesViewModel(service: MoviesService(httpClient: httpClient))
    }

    private func makeMovieDetailViewModel(for movieId: Int) -> MovieDetailViewModel {
        MovieDetailViewModel(
            movieId: movieId,
            service: MovieDetailService(httpClient: httpClient),
            accountService: accountService,
            sessionManager: sessionManager
        )
    }

    private func makeSeriesDetailViewModel(for seriesId: Int) -> SeriesDetailViewModel {
        SeriesDetailViewModel(
            seriesId: seriesId,
            service: SeriesDetailService(httpClient: httpClient),
            accountService: accountService,
            sessionManager: sessionManager
        )
    }

    private func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(
            service: WatchlistService(httpClient: HttpClient()),
            accountService: accountService,
            sessionManager: sessionManager
        )
    }

    private func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            service: FavoritesService(httpClient: httpClient),
            accountService: accountService,
            sessionManager: sessionManager
        )
    }

    private func makeMyStuffViewModel() -> MyStuffViewModel {
        MyStuffViewModel(
            service: MyStuffService(httpClient: httpClient),
            accountService: accountService,
            sessionManager: sessionManager
        )
    }

    private func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            service: ProfileService(
                accountService: accountService,
                genreService: GenreService(httpClient: httpClient)
            ),
            sessionManager: sessionManager,
            onLogout: logout
        )
    }

    private func logout() {
        isLoggedIn = false
    }
}
