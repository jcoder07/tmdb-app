//
//  Login.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import Foundation

final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    private let sessionKey = "tmdb_session_id"

    func saveSession(id: String) {
        UserDefaults.standard.set(id, forKey: sessionKey)
    }

    func getSession() -> String? {
        UserDefaults.standard.string(forKey: sessionKey)
    }

    func clearSession() {
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    var isLoggedIn: Bool {
        return getSession() != nil
    }
}

