//
//  SceneDelegate.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 05-01-26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Composition root: create dependencies here and inject them
        let sessionManager: SessionManagerProtocol = SessionManager()

        let mainViewController: UIViewController

        if sessionManager.isLoggedIn {
            mainViewController = HomeViewController(sessionManager: sessionManager)
        } else {
            mainViewController = LoginViewController(sessionManager: sessionManager)
        }

        let navigationController = UINavigationController(
            rootViewController: mainViewController
        )

        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = navigationController
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
