//
//  RemoteMovieDetailsRepositoryTests.swift
//  MvvmTests
//
//  Created by Juan Fernandez on 31-08-26.
//

import Testing
import Foundation
@testable import Mvvm


struct RemoteMovieDetailsRepositoryTests {


    @Test
    func getMovieDetailsReturnsMappedMovieOnSuccess() async throws {
        let dto = MovieDTO(originalTitle: "Interstellar", overview: "Una odisea espacial", popularity: 90.5)
        let mockClient = MockHTTPClient(result: .success(dto))
        let sut = RemoteMovieDetailRepository(httpClient: mockClient)

        let movie = try await sut.getMovieDetails()

        #expect(movie.originalTitle == dto.originalTitle)
        #expect(movie.overview == dto.overview)
        #expect(movie.popularity == dto.popularity)
    }

    @Test
    func getMovieDetailsPropagatesErrorOnFailure() async {
        struct TestError: Error {}
        let mockClient = MockHTTPClient(result: .failure(TestError()))
        let sut = RemoteMovieDetailRepository(httpClient: mockClient)

        await #expect(throws: TestError.self) {
            try await sut.getMovieDetails()
        }
    }
    
    @Test
    func getMovieDetailsRequestsTheExpectedURL() async throws {
        let dto = MovieDTO(originalTitle: "", overview: "", popularity: 0)
        let mockClient = MockHTTPClient(result: .success(dto))
        let sut = RemoteMovieDetailRepository(httpClient: mockClient)

        _ = try await sut.getMovieDetails()

        #expect(mockClient.capturedURL == Constants.Urls.movieDetail(id: 18))
    }
}

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    enum Result {
        case success(MovieDTO)
        case failure(Error)
    }
    
    private(set) var capturedURL: URL?
    private let result: Result

    init(result: Result) {
        self.result = result
    }

    func get<T: Decodable & Sendable>(url: URL, as type: T.Type) async throws -> T {
        capturedURL = url
        switch result {
        case .success(let dto):
            guard let typed = dto as? T else {
                fatalError("MockHTTPClient solo soporta MovieDTO en este ejercicio")
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
} // <- la clase se cierra aquí, sin el @Test adentro
