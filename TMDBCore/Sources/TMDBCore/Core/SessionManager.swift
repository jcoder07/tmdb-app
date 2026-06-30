import Foundation
import Security

public protocol SessionManagerProtocol: Sendable {
    func saveSession(id: String)
    func getSession() -> String?
    func clearSession()
    var isLoggedIn: Bool { get }
}

public final class SessionManager: SessionManagerProtocol {

    private let service = "com.tmdb-app"
    private let account = "session_id"

    public init() {}

    public func saveSession(id: String) {
        guard let data = id.data(using: .utf8) else { return }
        clearSession()
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    public func getSession() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func clearSession() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    public var isLoggedIn: Bool {
        getSession() != nil
    }
}
