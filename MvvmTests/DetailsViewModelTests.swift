//
//  DetailsViewModelTests.swift
//  MvvmTests
//
//  Created by Juan Fernandez on 18-08-26.
//
import Combine
import Foundation
import Testing
@testable import Mvvm

struct DetailsViewModelTests {
    
    @Test
    @MainActor
    func initialStateIsIdle() {
        let mock = MockMovieDetailRepository(result: .success(Movie(originalTitle: "", overview: "", popularity: 0)))
        let sut = DetailsViewModel(repository: mock)
        
        if case .idle = sut.state {
        } else {
            Issue.record("Se esperaba .idle, se obtuvo \(sut.state)")
        }
    }
    
    @Test
    @MainActor
    func getDetailsSuccessUpdatesStateToLoaded() async {
        //Arrange
        let expectedMovie = Movie(originalTitle: "Interstellar", overview: "Una odisea espacial", popularity: 90.0)
        let mock = MockMovieDetailRepository(result: .success(expectedMovie))
        let sut = DetailsViewModel(repository: mock)
        
        //Act
        await sut.getDetails()
        
        //Assert
        if case .loaded(let movie) = sut.state {
            #expect(movie.originalTitle == expectedMovie.originalTitle)
        } else {
            Issue.record("Se esperaba .loaded, se obtuvo \(sut.state)")
        }
    }
    
    @Test
    @MainActor
    func getDetailsFailureUpdatesStateToError() async {
        struct TestError: LocalizedError {
            var errorDescription: String? { "Algo salió mal" }
        }
        
        let mock = MockMovieDetailRepository(result: .failure(TestError()))
        let sut = DetailsViewModel(repository: mock)
        
        //Act
        await sut.getDetails()
        
        //Assert
        if case .error(let message) = sut.state {
            #expect(message == "Algo salió mal")
        } else {
            Issue.record("Se esperaba .error, se obtuvo \(sut.state)")
        }
    }
    
    @Test
    @MainActor
    func getDetailsPublishesLoadingBeforeLoaded() async {
        let expectedMovie = Movie(originalTitle: "Dune", overview: "...", popularity: 80.0)
        let mock = MockMovieDetailRepository(result: .success(expectedMovie))
        let sut = DetailsViewModel(repository: mock)

        var collectedStates: [ViewState<Movie>] = []
        let cancellable = sut.$state.sink { newState in
            collectedStates.append(newState)
        }

        await sut.getDetails()
        cancellable.cancel()

        #expect(collectedStates.count == 3)

        if case .idle = collectedStates[0] {} else {
            Issue.record("Posición 0 debería ser .idle")
        }
        if case .loading = collectedStates[1] {} else {
            Issue.record("Posición 1 debería ser .loading")
        }
        if case .loaded(let movie) = collectedStates[2] {
            #expect(movie.originalTitle == expectedMovie.originalTitle)
        } else {
            Issue.record("Posición 2 debería ser .loaded")
        }
    }
    
}







final class MockMovieDetailRepository: MovieDetailRepositoryProtocol {
    enum Result {
        case success(Movie)
        case failure(Error)
    }
    
    private let result: Result
    
    init(result: Result) {
        self.result = result
    }
    
    func getMovieDetails() async throws -> Movie {
        switch result {
        case .success(let movie):
            return movie
        case .failure(let error):
            throw error
        }
    }
}
