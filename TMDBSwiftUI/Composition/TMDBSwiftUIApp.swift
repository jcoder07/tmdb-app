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
    private let sessionManager: SessionManagerProtocol = SwiftDataSessionManager()
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

    @State private var isLoggedIn: Bool

    init(
        sessionManager: SessionManagerProtocol,
        httpClient: HttpClientProtocol
    ) {
        self.sessionManager = sessionManager
        self.httpClient = httpClient
        self.authService = TMDBAuthService(httpClient: httpClient)
        self._isLoggedIn = State(initialValue: sessionManager.isLoggedIn)
    }

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(
                    homeViewModel: makeHomeViewModel(),
                    moviesViewModel: makeMoviesViewModel(),
                    watchlistViewModel: makeWatchlistViewModel(),
                    favoritesViewModel: makeFavoritesViewModel(),
                    profileViewModel: makeProfileViewModel()
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

    private func makeMoviesViewModel() -> MoviesViewModel {
        MoviesViewModel(
            service: MoviesService(httpClient: httpClient),
            detailService: MovieDetailService(httpClient: httpClient),
            accountService: AccountService(httpClient: httpClient),
            sessionManager: sessionManager
        )
    }

    private func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(
            service: WatchlistService(httpClient: httpClient),
            accountService: AccountService(httpClient: httpClient),
            sessionManager: sessionManager
        )
    }

    private func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            service: FavoritesService(httpClient: httpClient),
            accountService: AccountService(httpClient: httpClient),
            sessionManager: sessionManager
        )
    }

    private func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            service: ProfileService(
                accountService: AccountService(httpClient: httpClient),
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
