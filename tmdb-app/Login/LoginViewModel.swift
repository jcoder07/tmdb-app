//
//  LoginViewModel.swift
//  tmdb-app
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let sessionManager: SessionManagerProtocol
    private let authService: TMDBAuthServiceProtocol
    private let onLoginSuccess: () -> Void

    init(sessionManager: SessionManagerProtocol, authService: TMDBAuthServiceProtocol, onLoginSuccess: @escaping () -> Void) {
        self.sessionManager = sessionManager
        self.authService = authService
        self.onLoginSuccess = onLoginSuccess
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        do {
            let tokenResponse = try await authService.createRequestToken()
            guard let token = tokenResponse.requestToken else {
                isLoading = false
                return
            }
            try await authService.validateLogin(username: username, password: password, requestToken: token)
            let session = try await authService.createSession(requestToken: token)
            sessionManager.saveSession(id: session.sessionId)
            onLoginSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
