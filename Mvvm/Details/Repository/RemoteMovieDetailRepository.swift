//
//  RemoteMovieDetailRepository.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

final class RemoteUserRepository: MovieDetailRepository {

    func getMovieDetails() async throws -> Movie? {

        let url = Constants.Urls.movieDetail(id: 18)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dto = try decoder.decode(
            MovieDTO.self,
            from: data
        )
        
        return Movie(dto)
    }
}
