import Foundation
import Observation

@MainActor
@Observable
public final class LoginViewModel {

    public var username = ""
    public var password = ""
    public var isLoading = false
    public var errorMessage: String?

    private let sessionManager: any SessionManagerProtocol
    private let authService: any TMDBAuthServiceProtocol
    private let onLoginSuccess: () -> Void

    public init(
        sessionManager: SessionManagerProtocol,
        authService: TMDBAuthServiceProtocol,
        onLoginSuccess: @escaping () -> Void
    ) {
        self.sessionManager = sessionManager
        self.authService = authService
        self.onLoginSuccess = onLoginSuccess
    }

    public func login() async {
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
