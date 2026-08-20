//
//  RemoteMovieDetailRepository.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

final class RemoteMovieDetailRepository: MovieDetailRepository {
    
    private let httpClient: HTTPClientProtocol
    
    public init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }

    func getMovieDetails() async throws -> Movie {

        let url = Constants.Urls.movieDetail(id: 18)

        let data = try await httpClient.get(url: url, as: MovieDTO.self)
        
        return Movie(data)
    }
}
