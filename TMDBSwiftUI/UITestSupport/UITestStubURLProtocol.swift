//
//  UITestStubURLProtocol.swift
//  TMDBSwiftUI
//

#if DEBUG

import Foundation

/// A `URLProtocol` that serves registered fixture responses instead of hitting the network.
///
/// Installed via `URLSessionConfiguration.protocolClasses` on the session handed to
/// `HttpClient(sessionProvider:)`, so it only affects the app's own requests and nothing is
/// registered globally. Compiled only in DEBUG: the shipping app never contains this type.
///
/// Ported from `TMDBSwiftUIIntegrationTests/Support/StubURLProtocol.swift`. The recording side of
/// that type is omitted because the UI test process runs out-of-process and can't read it back.
/// Added here is a body-builder route form, so one route can serve every `/movie/{id}` request
/// with a payload derived from the id rather than needing a route per fixture movie.
final class UITestStubURLProtocol: URLProtocol, @unchecked Sendable {

    private struct Route {
        let matches: @Sendable (URL) -> Bool
        let statusCode: Int
        let body: @Sendable (URL) -> String
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var routes: [Route] = []

    // MARK: - Configuration

    static func reset() {
        lock.lock()
        routes = []
        lock.unlock()
    }

    /// Registers a fixed response for a path suffix, optionally narrowed by the query items.
    ///
    /// The match is on path *suffix* rather than equality because `Constants.baseURL` carries
    /// the TMDB API version prefix ("/3"), while callers register paths like "/movie/popular".
    static func stub(
        path: String,
        matchingQuery matchesQuery: (@Sendable ([URLQueryItem]) -> Bool)? = nil,
        statusCode: Int = 200,
        json: String
    ) {
        stub(
            matching: { url in
                guard url.path.hasSuffix(path) else { return false }
                guard let matchesQuery else { return true }
                let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
                return matchesQuery(items)
            },
            statusCode: statusCode,
            body: { _ in json }
        )
    }

    /// Registers a response built from the request URL — used for id-bearing paths such as
    /// `/movie/{id}`, so the served payload matches whichever item the test tapped.
    static func stub(
        matching matches: @escaping @Sendable (URL) -> Bool,
        statusCode: Int = 200,
        body: @escaping @Sendable (URL) -> String
    ) {
        lock.lock()
        routes.append(Route(matches: matches, statusCode: statusCode, body: body))
        lock.unlock()
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [UITestStubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        Self.lock.lock()
        // First match wins, so `UITestEnvironment` registers narrow routes before broad ones.
        let match = Self.routes.first { $0.matches(url) }
        Self.lock.unlock()

        // No route means a request the harness didn't anticipate. Failing loudly surfaces as a
        // visible error state in the UI, which is what the test should catch — far better than
        // silently letting the request reach the live API.
        guard let match else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: match.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(match.body(url).utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

#endif
