import Testing
import Foundation
@testable import TMDBCore

// Uses MockHttpClient (Spy) from TestDoubles.swift

struct AuthServiceTests {

    private func makeSUT(client: MockHttpClient = MockHttpClient()) -> TMDBAuthService {
        TMDBAuthService(httpClient: client)
    }

    // MARK: - createRequestToken

    @Test func createRequestTokenReturnsToken() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            RequestTokenResponse(success: true, expiresAt: "2024-01-01T00:00:00", requestToken: "token-abc")
        ]

        let result = try await makeSUT(client: client).createRequestToken()

        #expect(result.requestToken == "token-abc")
        #expect(result.success == true)
    }

    @Test func createRequestTokenUsesCorrectURL_usingSpyClient() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            RequestTokenResponse(success: true, expiresAt: nil, requestToken: "t")
        ]

        _ = try await makeSUT(client: client).createRequestToken()

        #expect(client.capturedURLs.count == 1)
        #expect(client.capturedURLs[0].absoluteString.contains("token/new"))
    }

    @Test func createRequestTokenThrowsOnNetworkError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.badRequest

        await #expect(throws: NetworkError.self) {
            try await makeSUT(client: client).createRequestToken()
        }
    }

    // MARK: - validateLogin

    @Test func validateLoginSendsPostRequest_usingSpyClient() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            RequestTokenResponse(success: true, expiresAt: nil, requestToken: "token-abc")
        ]

        try await makeSUT(client: client).validateLogin(username: "user", password: "pass", requestToken: "token-abc")

        #expect(client.capturedURLs.count == 1)
        #expect(client.capturedMethods[0] == "POST")
        #expect(client.capturedURLs[0].absoluteString.contains("validate_with_login"))
    }

    @Test func validateLoginThrowsOnServerError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.serverError("Invalid credentials.")

        await #expect(throws: NetworkError.self) {
            try await makeSUT(client: client).validateLogin(username: "bad", password: "creds", requestToken: "tok")
        }
    }

    // MARK: - createSession

    @Test func createSessionReturnsSessionId() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            CreateSessionResponse(success: true, sessionId: "session-xyz")
        ]

        let result = try await makeSUT(client: client).createSession(requestToken: "tok")

        #expect(result.sessionId == "session-xyz")
        #expect(result.success == true)
    }

    @Test func createSessionSendsPostRequest_usingSpyClient() async throws {
        let client = MockHttpClient()
        client.stubbedResponses = [
            CreateSessionResponse(success: true, sessionId: "s")
        ]

        _ = try await makeSUT(client: client).createSession(requestToken: "tok")

        #expect(client.capturedMethods[0] == "POST")
        #expect(client.capturedURLs[0].absoluteString.contains("session/new"))
    }

    @Test func createSessionThrowsOnNetworkError() async {
        let client = MockHttpClient()
        client.errorToThrow = NetworkError.invalidResponse

        await #expect(throws: NetworkError.self) {
            try await makeSUT(client: client).createSession(requestToken: "tok")
        }
    }
}
