import Foundation

public protocol TMDBAuthServiceProtocol {
    func createRequestToken() async throws -> RequestTokenResponse
    func validateLogin(username: String, password: String, requestToken: String) async throws
    func createSession(requestToken: String) async throws -> CreateSessionResponse
}

public final class TMDBAuthService: TMDBAuthServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func createRequestToken() async throws -> RequestTokenResponse {
        let resource = Resource(url: Constants.Urls.requestToken, modelType: RequestTokenResponse.self)
        return try await httpClient.load(resource)
    }

    public func validateLogin(username: String, password: String, requestToken: String) async throws {
        let resource = try Resource(
            url: Constants.Urls.validateLogin,
            body: ValidateLoginRequest(username: username, password: password, requestToken: requestToken),
            modelType: RequestTokenResponse.self
        )
        _ = try await httpClient.load(resource)
    }

    public func createSession(requestToken: String) async throws -> CreateSessionResponse {
        let resource = try Resource(
            url: Constants.Urls.createSession,
            body: CreateSessionRequest(requestToken: requestToken),
            modelType: CreateSessionResponse.self
        )
        return try await httpClient.load(resource)
    }
}
