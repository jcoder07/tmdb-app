import Foundation
import TMDBCore

// App-layer ViewModel — navigation logic only, no observable state needed.
// Mirrors the TMDBSwiftUI HomeViewModel.
final class HomeViewModel {

    private let sessionManager: SessionManagerProtocol
    private let onLogout: () -> Void

    init(sessionManager: SessionManagerProtocol, onLogout: @escaping () -> Void) {
        self.sessionManager = sessionManager
        self.onLogout = onLogout
    }

    func logout() {
        sessionManager.clearSession()
        onLogout()
    }
}
