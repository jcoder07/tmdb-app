//
//  TMDBConfig.swift
//  tmdb-app
//

import Foundation

enum TMDBConfig {
    static let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
    static let baseURL = "https://api.themoviedb.org/3"
}
