//
//  RemoteMovieDetailRepository.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

final class RemoteUserRepository: MovieDetailRepository {
    
    private let httpClient: HttpClientProtocol
    
    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    func getMovieDetails() async throws -> Movie? {

        let url = Constants.Urls.movieDetail(id: 18)

        let data = try await httpClient.get(url: url)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dto = try decoder.decode(
            MovieDTO.self,
            from: data
        )
        
        return Movie(dto)
    }
}
