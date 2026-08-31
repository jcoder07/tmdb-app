//
//  URLSessionHTTPClientTests.swift
//  MvvmTests
//
//  Created by Juan Fernandez on 31-08-26.
//

import Testing
import Foundation
@testable import Mvvm

struct URLSessionHTTPClientTests {

    @Test
    func getReturnsDecodedValueOnSuccessResponse() async throws {
        let payload = StubPayload(title: "Interstellar", value: 90.5)
        let session = MockURLSession(result: .success(data: makePayloadData(payload), statusCode: 200))
        let sut = URLSessionHTTPClient(session: session, decoder: JSONDecoder())

        let result = try await sut.get(url: anyURL(), as: StubPayload.self)

        #expect(result == payload)
    }

    @Test(arguments: [200, 250, 299])
    func getSucceedsForAny2xxStatusCode(_ statusCode: Int) async throws {
        let payload = StubPayload(title: "Dune", value: 50)
        let session = MockURLSession(result: .success(data: makePayloadData(payload), statusCode: statusCode))
        let sut = URLSessionHTTPClient(session: session, decoder: JSONDecoder())

        let result = try await sut.get(url: anyURL(), as: StubPayload.self)

        #expect(result == payload)
    }

    @Test(arguments: [199, 300, 400, 500])
    func getThrowsOnNonSuccessStatusCode(_ statusCode: Int) async {
        let session = MockURLSession(result: .success(data: Data(), statusCode: statusCode))
        let sut = URLSessionHTTPClient(session: session, decoder: JSONDecoder())

        await #expect(throws: URLError.self) {
            _ = try await sut.get(url: anyURL(), as: StubPayload.self)
        }
    }

    @Test
    func getThrowsBadServerResponseCodeOnFailureStatus() async {
        let session = MockURLSession(result: .success(data: Data(), statusCode: 404))
        let sut = URLSessionHTTPClient(session: session, decoder: JSONDecoder())

        do {
            _ = try await sut.get(url: anyURL(), as: StubPayload.self)
            Issue.record("Se esperaba que get lanzara un error")
        } catch let error as URLError {
            #expect(error.code == .badServerResponse)
        } catch {
            Issue.record("Error inesperado: \(error)")
        }
    }

    @Test
    func getPropagatesErrorFromSession() async {
        struct TestError: Error {}
        let session = MockURLSession(result: .failure(TestError()))
        let sut = URLSessionHTTPClient(session: session, decoder: JSONDecoder())

        await #expect(throws: TestError.self) {
            _ = try await sut.get(url: anyURL(), as: StubPayload.self)
        }
    }

    @Test
    func getThrowsOnInvalidData() async {
        let invalidData = Data("not json".utf8)
        let session = MockURLSession(result: .success(data: invalidData, statusCode: 200))
        let sut = URLSessionHTTPClient(session: session, decoder: JSONDecoder())

        await #expect(throws: DecodingError.self) {
            _ = try await sut.get(url: anyURL(), as: StubPayload.self)
        }
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    private func makePayloadData(_ payload: StubPayload) -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "title": payload.title,
            "value": payload.value
        ])
    }
}

private nonisolated struct StubPayload: Decodable, Sendable, Equatable {
    let title: String
    let value: Double
}

struct MockURLSession: URLSessionProtocol {
    enum Result {
        case success(data: Data, statusCode: Int)
        case failure(Error)
    }

    let result: Result

    func data(
        from url: URL,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse) {
        switch result {
        case .success(let data, let statusCode):
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
}
