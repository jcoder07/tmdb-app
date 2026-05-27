//
//  LoginControllerView.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Usuario"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contraseña"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Iniciar sesión", for: .normal)
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Login"
        
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            usernameTextField,
            passwordTextField,
            loginButton
        ])
        
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    private func goToHome() {
        let homeVC = HomeViewController()
        navigationController?.setViewControllers([homeVC], animated: true)
    }

    // MARK: - Actions
    
    @objc private func loginTapped() {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        let authService = TMDBAuthService()
        
        authService.createRequestToken { [weak self] result in
            switch result {
            case .success(let tokenResponse):
                guard let token = tokenResponse.requestToken else { return }
                
                authService.validateLogin(
                    username: username,
                    password: password,
                    requestToken: token
                ) { result in
                    switch result {
                    case .success:
                        authService.createSession(requestToken: token) { result in
                            switch result {
                            case .success(let sessionResponse):
                                SessionManager.shared.saveSession(
                                    id: sessionResponse.sessionId
                                )
                                
                                DispatchQueue.main.async {
                                    self?.goToHome()
                                }
                                
                            case .failure(let error):
                                print("❌ Session error:", error)
                            }
                        }
                        
                    case .failure(let error):
                        print("❌ Login error:", error)
                    }
                }
                
            case .failure(let error):
                print("❌ Token error:", error)
            }
        }
    }
}


struct ITunesSearchResponse: Decodable {
    let resultCount: Int
    let results: [Song]
}

struct Song: Decodable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let collectionName: String?
    let previewUrl: URL?
}

