import Foundation

/// A `URLProtocol` that serves pre-registered fixture responses instead of hitting the network.
/// Installed via `URLSessionConfiguration.protocolClasses` on a per-test session, so nothing
/// ever leaves the process and no test can accidentally reach the live TMDB API.
final class StubURLProtocol: URLProtocol, @unchecked Sendable {

    struct RecordedRequest: Sendable {
        let url: URL
        let method: String
        let body: Data?
    }

    private struct Route {
        let path: String
        let matchesQuery: (@Sendable ([URLQueryItem]) -> Bool)?
        let statusCode: Int
        let data: Data
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var routes: [Route] = []
    nonisolated(unsafe) private static var recorded: [RecordedRequest] = []
    nonisolated(unsafe) private static var unexpectedRequests: [URL] = []

    // MARK: - Test-facing configuration

    static func reset() {
        lock.lock()
        routes = []
        recorded = []
        unexpectedRequests = []
        lock.unlock()
    }

    static func stub(
        path: String,
        matchingQuery matchesQuery: (@Sendable ([URLQueryItem]) -> Bool)? = nil,
        statusCode: Int = 200,
        json: String
    ) {
        lock.lock()
        routes.append(Route(path: path, matchesQuery: matchesQuery, statusCode: statusCode, data: Data(json.utf8)))
        lock.unlock()
    }

    static var recordedRequests: [RecordedRequest] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }

    static var unexpectedRequestURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return unexpectedRequests
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
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

        let method = request.httpMethod ?? "GET"
        let body = Self.readBody(from: request)
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        Self.lock.lock()
        Self.recorded.append(RecordedRequest(url: url, method: method, body: body))
        // Suffix match rather than exact equality: `Constants.baseURL` includes the API
        // version path ("/3"), which stubs register without, e.g. "/movie/popular".
        let match = Self.routes.first { route in
            guard url.path.hasSuffix(route.path) else { return false }
            guard let matchesQuery = route.matchesQuery else { return true }
            return matchesQuery(queryItems)
        }
        if match == nil { Self.unexpectedRequests.append(url) }
        Self.lock.unlock()

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
        client?.urlProtocol(self, didLoad: match.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    /// `URLSession` moves `httpBody` into `httpBodyStream` before invoking the protocol,
    /// so `request.httpBody` is `nil` here even for a POST created with an explicit body.
    private static func readBody(from request: URLRequest) -> Data? {
        guard let stream = request.httpBodyStream else { return request.httpBody }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: bufferSize)
            if read <= 0 { break }
            data.append(buffer, count: read)
        }
        return data
    }
}
