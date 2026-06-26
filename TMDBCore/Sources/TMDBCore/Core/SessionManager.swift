import Foundation

public protocol SessionManagerProtocol {
    func saveSession(id: String)
    func getSession() -> String?
    func clearSession()
    var isLoggedIn: Bool { get }
}

public final class SessionManager: SessionManagerProtocol {

    private let sessionKey = "tmdb_session_id"

    public init() {}

    public func saveSession(id: String) {
        UserDefaults.standard.set(id, forKey: sessionKey)
    }

    public func getSession() -> String? {
        UserDefaults.standard.string(forKey: sessionKey)
    }

    public func clearSession() {
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    public var isLoggedIn: Bool {
        getSession() != nil
    }
}
