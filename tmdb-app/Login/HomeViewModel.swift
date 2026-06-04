//
//  HomeViewModel.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import Foundation

final class HomeViewModel: ObservableObject {

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
