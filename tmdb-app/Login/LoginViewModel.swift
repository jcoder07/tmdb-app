//
//  LoginViewModel.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import Foundation

final class LoginViewModel: ObservableObject {

    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let sessionManager: SessionManagerProtocol
    private let onLoginSuccess: () -> Void

    init(sessionManager: SessionManagerProtocol, onLoginSuccess: @escaping () -> Void) {
        self.sessionManager = sessionManager
        self.onLoginSuccess = onLoginSuccess
    }

    func login() {
        isLoading = true
        errorMessage = nil

        let authService = TMDBAuthService()

        authService.createRequestToken { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let tokenResponse):
                guard let token = tokenResponse.requestToken else {
                    DispatchQueue.main.async { self.isLoading = false }
                    return
                }
                authService.validateLogin(
                    username: username,
                    password: password,
                    requestToken: token
                ) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        authService.createSession(requestToken: token) { [weak self] result in
                            guard let self else { return }
                            DispatchQueue.main.async {
                                self.isLoading = false
                                switch result {
                                case .success(let sessionResponse):
                                    self.sessionManager.saveSession(id: sessionResponse.sessionId)
                                    self.onLoginSuccess()
                                case .failure(let error):
                                    self.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
