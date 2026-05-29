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
        let authService: TMDBAuthServiceProtocol = TMDBAuthService()

        guard let windowScene = scene as? UIWindowScene else { return }

        let nav = UINavigationController()

        func makeLoginVC() -> UIViewController {
            let viewModel = LoginViewModel(sessionManager: sessionManager, authService: authService, onLoginSuccess: {
                nav.setViewControllers([makeHomeVC()], animated: true)
            })
            return UIHostingController(rootView: LoginView(viewModel: viewModel))
        }

        func makeHomeVC() -> HomeViewController {
            HomeViewController(sessionManager: sessionManager) {
                nav.setViewControllers([makeLoginVC()], animated: true)
            }
        }

        nav.setViewControllers([sessionManager.isLoggedIn ? makeHomeVC() : makeLoginVC()], animated: false)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
}
