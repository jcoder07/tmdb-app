import Testing
import TMDBCore
@testable import TMDBSwiftUI

extension TMDBSwiftUIIntegrationTests {

@Suite
struct SessionPersistenceIntegrationTests {

    // MARK: - Keychain-backed SessionManager (what the app actually uses)

    @Test func keychainSessionManagerRoundTripsAndClears() {
        let sut = SessionManager()
        sut.clearSession()
        defer { sut.clearSession() }

        #expect(sut.getSession() == nil)
        #expect(sut.isLoggedIn == false)

        sut.saveSession(id: "keychain-fixture-session")

        #expect(sut.getSession() == "keychain-fixture-session")
        #expect(sut.isLoggedIn == true)

        sut.clearSession()

        #expect(sut.getSession() == nil)
        #expect(sut.isLoggedIn == false)
    }

    @Test func keychainSessionManagerReplacesRatherThanAccumulates() {
        let sut = SessionManager()
        sut.clearSession()
        defer { sut.clearSession() }

        sut.saveSession(id: "first-session")
        sut.saveSession(id: "second-session")

        #expect(sut.getSession() == "second-session")
    }

    // MARK: - SwiftDataSessionManager (declared but never wired into the composition root)

    @Test func swiftDataSessionManagerRoundTripsAndClears() {
        let sut = SwiftDataSessionManager(isStoredInMemoryOnly: true)

        #expect(sut.getSession() == nil)
        #expect(sut.isLoggedIn == false)

        sut.saveSession(id: "swiftdata-fixture-session")

        #expect(sut.getSession() == "swiftdata-fixture-session")
        #expect(sut.isLoggedIn == true)

        sut.clearSession()

        #expect(sut.getSession() == nil)
        #expect(sut.isLoggedIn == false)
    }

    @Test func swiftDataSessionManagerReplacesRatherThanAccumulates() {
        let sut = SwiftDataSessionManager(isStoredInMemoryOnly: true)

        sut.saveSession(id: "first-session")
        sut.saveSession(id: "second-session")

        #expect(sut.getSession() == "second-session")
    }
}

}
