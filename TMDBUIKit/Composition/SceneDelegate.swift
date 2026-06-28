//
//  SceneDelegate.swift
//  TMDBUIKit
//
//  Created by Miguel Duran on 26-06-26.
//

import UIKit
import TMDBCore

// MARK: - Composition Root

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Shared infrastructure — lives for the app's lifetime, mirroring TMDBSwiftUIApp
    private let sessionManager: SessionManagerProtocol = SessionManager()
    private let httpClient: HttpClientProtocol = HttpClient()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = sessionManager.isLoggedIn ? makeTabBar() : makeLoginNav()
        window.makeKeyAndVisible()
    }

    // MARK: - Factory functions

    private func makeLoginNav() -> UINavigationController {
        let vm = LoginViewModel(
            sessionManager: sessionManager,
            authService: TMDBAuthService(httpClient: httpClient),
            onLoginSuccess: { [weak self] in
                guard let self else { return }
                self.transition(to: self.makeTabBar())
            }
        )
        return UINavigationController(rootViewController: LoginViewController(viewModel: vm))
    }

    private func makeTabBar() -> UITabBarController {
        let tabBar = UITabBarController()

        let profileVM = ProfileViewModel(
            service: ProfileService(
                accountService: AccountService(httpClient: httpClient),
                genreService: GenreService(httpClient: httpClient)
            ),
            sessionManager: sessionManager,
            onLogout: { [weak self] in
                guard let self else { return }
                self.transition(to: self.makeLoginNav())
            }
        )

        let homeVC = HomeViewController(
            viewModel: HomeViewModel(
                sessionManager: sessionManager,
                onLogout: { [weak self] in
                    guard let self else { return }
                    self.transition(to: self.makeLoginNav())
                }
            ),
            profileViewModel: profileVM,
            onGoToWatchlist: { tabBar.selectedIndex = 3 }
        )

        let moviesVC = MoviesViewController(
            viewModel: MoviesViewModel(
                service: MoviesService(httpClient: httpClient),
                detailService: MovieDetailService(httpClient: httpClient)
            )
        )

        let watchlistVC = WatchlistViewController(
            viewModel: WatchlistViewModel(
                service: WatchlistService(httpClient: httpClient),
                sessionManager: sessionManager
            )
        )

        let tabs: [(UIViewController, String, String)] = [
            (homeVC,                  "Home",      "house"),
            (moviesVC,                "Movies",    "film"),
            (SeriesViewController(),  "Series",    "tv"),
            (watchlistVC,             "Watchlist", "bookmark"),
            (SearchViewController(),  "Search",    "magnifyingglass"),
        ]

        tabBar.viewControllers = tabs.enumerated().map { index, entry in
            let nav = UINavigationController(rootViewController: entry.0)
            nav.tabBarItem = UITabBarItem(title: entry.1, image: UIImage(systemName: entry.2), tag: index)
            return nav
        }

        return tabBar
    }

    private func transition(to vc: UIViewController) {
        guard let window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = vc
        }
    }
}

