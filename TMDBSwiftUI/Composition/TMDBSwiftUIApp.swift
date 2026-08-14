//
//  TMDBSwiftUIApp.swift
//  TMDBSwiftUI
//

import SwiftUI
import TMDBCore

@main
struct TMDBSwiftUIApp: App {
    private let sessionManager: SessionManagerProtocol = SessionManager()
    private let httpClient: HttpClientProtocol = HttpClient()
    @AppStorage("appColorScheme") private var storedScheme: Int = 0

    private var preferredScheme: ColorScheme? {
        switch storedScheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                sessionManager: sessionManager,
                httpClient: httpClient
            )
            .preferredColorScheme(preferredScheme)
        }
    }
}

// Holds isLoggedIn as @Observable so login/logout closures always update
// the single preserved instance regardless of how many times AppRootView.init runs.
@Observable
private final class AppSessionState {
    var isLoggedIn: Bool
    init(isLoggedIn: Bool) { self.isLoggedIn = isLoggedIn }
}

private struct AppRootView: View {
    // Services — stable references passed from TMDBSwiftUIApp
    private let sessionManager: any SessionManagerProtocol
    private let httpClient: any HttpClientProtocol
    private let authService: any TMDBAuthServiceProtocol
    private let accountService: any AccountServiceProtocol

    // Auth state lives in an @Observable class so closures captured at init
    // time always point to the one preserved instance.
    @State private var sessionState: AppSessionState

    // Long-lived ViewModels stored as @State so they survive body re-evaluations
    // triggered by theme changes or other environment updates.
    @State private var homeViewModel: HomeViewModel
    @State private var moviesViewModel: MoviesViewModel
    @State private var seriesViewModel: SeriesViewModel
    @State private var watchlistViewModel: WatchlistViewModel
    @State private var favoritesViewModel: FavoritesViewModel
    @State private var myStuffViewModel: MyStuffViewModel
    @State private var profileViewModel: ProfileViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var showSplash = true

    init(
        sessionManager: any SessionManagerProtocol,
        httpClient: any HttpClientProtocol
    ) {
        let authService: any TMDBAuthServiceProtocol = TMDBAuthService(httpClient: httpClient)
        let accountService: any AccountServiceProtocol = AccountServiceCacheDecorator(
            decoratee: AccountService(httpClient: httpClient)
        )
        let sessionState = AppSessionState(isLoggedIn: sessionManager.isLoggedIn)

        self.sessionManager = sessionManager
        self.httpClient = httpClient
        self.authService = authService
        self.accountService = accountService
        self._sessionState = State(initialValue: sessionState)

        self._homeViewModel = State(initialValue: HomeViewModel(
            service: HomeService(httpClient: httpClient),
            sessionManager: sessionManager,
            onLogout: {}
        ))
        self._moviesViewModel = State(initialValue: MoviesViewModel(
            service: MoviesService(httpClient: httpClient)
        ))
        self._seriesViewModel = State(initialValue: SeriesViewModel(
            service: SeriesService(httpClient: httpClient)
        ))
        self._watchlistViewModel = State(initialValue: WatchlistViewModel(
            service: WatchlistService(httpClient: HttpClient()),
            accountService: accountService,
            sessionManager: sessionManager
        ))
        self._favoritesViewModel = State(initialValue: FavoritesViewModel(
            service: FavoritesService(httpClient: httpClient),
            accountService: accountService,
            sessionManager: sessionManager
        ))
        self._myStuffViewModel = State(initialValue: MyStuffViewModel(
            service: MyStuffService(httpClient: httpClient),
            accountService: accountService,
            sessionManager: sessionManager
        ))
        self._profileViewModel = State(initialValue: ProfileViewModel(
            service: ProfileService(
                accountService: accountService,
                genreService: GenreService(httpClient: httpClient)
            ),
            sessionManager: sessionManager,
            onLogout: { sessionState.isLoggedIn = false }
        ))
        self._searchViewModel = State(initialValue: SearchViewModel(
            searchService: SearchService(httpClient: httpClient),
            genreService: GenreService(httpClient: httpClient)
        ))
    }

    var body: some View {
        ZStack {
            // Main content loads in the background during the splash so it's
            // ready as soon as the animation finishes.
            MainTabView(
                homeViewModel: homeViewModel,
                moviesViewModel: moviesViewModel,
                seriesViewModel: seriesViewModel,
                watchlistViewModel: watchlistViewModel,
                favoritesViewModel: favoritesViewModel,
                myStuffViewModel: myStuffViewModel,
                profileViewModel: profileViewModel,
                searchViewModel: searchViewModel,
                makeMovieDetailViewModel: { self.makeMovieDetailViewModel(for: $0) },
                makeSeriesDetailViewModel: { self.makeSeriesDetailViewModel(for: $0) },
                makePersonDetailViewModel: { self.makePersonDetailViewModel(for: $0) },
                makeGenreResultsViewModel: { self.makeGenreResultsViewModel(for: $0) },
                makeBrowseResultsViewModel: { self.makeBrowseResultsViewModel(for: $0) },
                isLoggedIn: sessionState.isLoggedIn,
                makeLoginViewModel: {
                    return LoginViewModel(
                        sessionManager: self.sessionManager,
                        authService: self.authService,
                        onLoginSuccess: { self.sessionState.isLoggedIn = true }
                    )
                }
            )

            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .zIndex(1)
                .transition(.opacity)
            }
        }
    }

    // Detail ViewModels are created per-use (not long-lived)
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

    private func makePersonDetailViewModel(for personId: Int) -> PersonDetailViewModel {
        PersonDetailViewModel(personId: personId, service: PersonService(httpClient: httpClient))
    }

    private func makeGenreResultsViewModel(for genre: GenreItem) -> GenreResultsViewModel {
        GenreResultsViewModel(genre: genre, service: SearchService(httpClient: httpClient))
    }

    private func makeBrowseResultsViewModel(for kind: BrowseKind) -> BrowseResultsViewModel {
        BrowseResultsViewModel(
            kind: kind,
            moviesService: MoviesService(httpClient: httpClient),
            seriesService: SeriesService(httpClient: httpClient),
            personService: PersonService(httpClient: httpClient)
        )
    }
}

// MARK: - SplashView

private struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var logoScale: CGFloat = 0.75
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0

    let onFinished: () -> Void

    private var bgColor: Color {
        colorScheme == .dark ? Color(hex: "1C1812") : Color(hex: "F5EDD8")
    }
    private let gold = Color(hex: "C5A55A")

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack(spacing: 28) {
                Image("AppLogo")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(gold)
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text("TMDB")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(gold)
                        .tracking(12)

                    Text("THE MOVIE DATABASE")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(gold.opacity(0.6))
                        .tracking(4)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
            }
            Task {
                try? await Task.sleep(nanoseconds: 2_300_000_000)
                onFinished()
            }
        }
    }
}
