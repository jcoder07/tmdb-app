//
//  TMDBAuthService.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 06-01-26.
//

import Foundation

final class TMDBAuthService {

    private let apiKey = "TU_API_KEY_V3"
    private let baseURL = "https://api.themoviedb.org/3"

    func createRequestToken(
        completion: @escaping (Result<RequestTokenResponse, Error>) -> Void
    ) {

        let urlString = "\(baseURL)/authentication/token/new?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(RequestTokenResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
}



