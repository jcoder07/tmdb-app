//
//  SceneDelegate.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 05-01-26.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Composition root: all dependencies and view controllers are created here
        let sessionManager: SessionManagerProtocol = SessionManager()
        let httpClient: HttpClientProtocol = HttpClient()
        let authService: TMDBAuthServiceProtocol = TMDBAuthService(httpClient: httpClient)

        guard let windowScene = scene as? UIWindowScene else { return }

        let nav = UINavigationController()

        func makeLoginVC() -> UIViewController {
            nav.setNavigationBarHidden(false, animated: true)
            let viewModel = LoginViewModel(sessionManager: sessionManager, authService: authService, onLoginSuccess: {
                nav.setViewControllers([makeMainTabVC()], animated: true)
            })
            return UIHostingController(rootView: LoginView(viewModel: viewModel))
        }

        func makeMainTabVC() -> UIViewController {
            nav.setNavigationBarHidden(true, animated: true)
            let homeViewModel = HomeViewModel(sessionManager: sessionManager, onLogout: {
                nav.setViewControllers([makeLoginVC()], animated: true)
            })
            let moviesViewModel = MoviesViewModel(service: MoviesService(httpClient: httpClient))
            let watchlistViewModel = WatchlistViewModel(
                service: WatchlistService(httpClient: httpClient),
                sessionManager: sessionManager
            )
            let profileViewModel = ProfileViewModel(
                service: ProfileService(
                    accountService: AccountService(httpClient: httpClient),
                    genreService: GenreService(httpClient: httpClient)
                ),
                sessionManager: sessionManager,
                onLogout: {
                    nav.setViewControllers([makeLoginVC()], animated: true)
                }
            )
            return UIHostingController(rootView: MainTabView(
                homeViewModel: homeViewModel,
                moviesViewModel: moviesViewModel,
                watchlistViewModel: watchlistViewModel,
                profileViewModel: profileViewModel
            ))
        }

        nav.setViewControllers([sessionManager.isLoggedIn ? makeMainTabVC() : makeLoginVC()], animated: false)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
}
