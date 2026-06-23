//
//  Constants.swift
//  tmdb-app
//

import Foundation

struct Constants {

    private static let base = TMDBConfig.baseURL
    private static let key = TMDBConfig.apiKey

    struct Urls {

        // MARK: - Authentication
        static let requestToken = URL(string: "\(base)/authentication/token/new?api_key=\(key)")!
        static let validateLogin = URL(string: "\(base)/authentication/token/validate_with_login?api_key=\(key)")!
        static let createSession = URL(string: "\(base)/authentication/session/new?api_key=\(key)")!

        // MARK: - Account
        static func account(sessionId: String) -> URL {
            URL(string: "\(base)/account?api_key=\(key)&session_id=\(sessionId)")!
        }

        static func ratedMovies(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/rated/movies?api_key=\(key)&session_id=\(sessionId)")!
        }

        static func ratedTVShows(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/rated/tv?api_key=\(key)&session_id=\(sessionId)")!
        }

        // MARK: - Watchlist
        static func watchlistMovies(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/watchlist/movies?api_key=\(key)&session_id=\(sessionId)")!
        }

        static func watchlistTVShows(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/watchlist/tv?api_key=\(key)&session_id=\(sessionId)")!
        }

        // MARK: - Movies
        static func popularMovies(page: Int = 1) -> URL {
            URL(string: "\(base)/movie/popular?api_key=\(key)&page=\(page)")!
        }

        static func movieDetail(id: Int) -> URL {
            URL(string: "\(base)/movie/\(id)?api_key=\(key)")!
        }

        static func movieCredits(id: Int) -> URL {
            URL(string: "\(base)/movie/\(id)/credits?api_key=\(key)")!
        }

        static func movieReviews(id: Int) -> URL {
            URL(string: "\(base)/movie/\(id)/reviews?api_key=\(key)")!
        }

        static func backdrop(path: String) -> URL? {
            URL(string: "https://image.tmdb.org/t/p/w780\(path)")
        }

        // MARK: - Genres
        static let movieGenres = URL(string: "\(base)/genre/movie/list?api_key=\(key)")!
        static let tvGenres = URL(string: "\(base)/genre/tv/list?api_key=\(key)")!

        // MARK: - Images
        static func poster(path: String) -> URL? {
            URL(string: "https://image.tmdb.org/t/p/w185\(path)")
        }

        static func gravatar(hash: String) -> URL {
            URL(string: "https://www.gravatar.com/avatar/\(hash)?s=185&d=404")!
        }
    }
}
